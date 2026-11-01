import host.sim.template.a4pre_first_tail_x15_r0_body.m.B27
import host.sim.conv.Closed
import host.sim.conv.NClean
import host.sim.conv.CompactFull
import host.sim.template.FootGen
import host.sim.template.a4pre_first_tail_x15_r0_body.States
import host.sim.template.a4pre_first_tail_x15_r0_body.m.B00
import host.sim.conv.MergeSt
import host.sim.conv.Fresh
import host.sim.conv.CallPieces
import host.sim.stage.Mlx
import host.sim.template.NShiftOf
import host.sim.template.FullShiftGen
import host.sim.template.CallGen
import host.sim.template.EndGen
import host.sim.conv.CompactShift
import host.sim.template.Check
import host.sim.BigFreeP
import host.sim.template.BootEq
import host.sim.StageRel
import host.sim.compose.a4b.VWFramesDefs
import host.sim.template.FullOk
import host.sim.template.FastOk
import host.sim.Chunk
import host.sim.conv.Compact
import host.sim.native.RebigR
import host.sim.template.Sigma
import host.sim.template.NShiftGen

section -- SiteK132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl132`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl132 : List Nat := [2665, 2672641, 2673467, 2778209, 2778754, 2779010, 2779035, 2779036, 2779037, 2779038, 2779039, 2779040]
def PRE_first_tail_x15_r0_body.clo132 : List Nat := [20792, 20805, 20811, 20812, 20813, 20814]
def PRE_first_tail_x15_r0_body.cln132 : List Nat := [17885, 17886, 17887, 17888, 17889, 17890, 17891, 17892, 17893, 17894, 17895, 17896, 17897, 17898, 17899, 17900, 17901, 17902, 17903, 17904, 17905, 17906, 17907, 17908, 17909, 17910, 17911]
def PRE_first_tail_x15_r0_body.cli132 : List Nat := [17885, 17886, 17887, 17888, 17889, 17890, 17891, 17892, 17893, 17894, 17895, 17896, 17897, 17898, 17899, 17900, 17901, 17902, 17903, 17904, 17905, 17906, 17907, 17908, 17909, 17910, 17911]
kernel_rfl PRE_first_tail_x15_r0_body.cheap132 : PRE_first_tail_x15_r0_body.s1283.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1281.heap (PRE_first_tail_x15_r0_body.cl132.filterMap fun a => (PRE_first_tail_x15_r0_body.s1283.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe132 : Nat.ble PRE_first_tail_x15_r0_body.s1281.next PRE_first_tail_x15_r0_body.s1283.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP132 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp132 : Conv.suppListB PRE_first_tail_x15_r0_body.s1283 5744 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound132 : Conv.boundListB PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst132 : Conv.sstListB 5744 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cli132 = true

end Host.Load.Run.Tpl
end

section -- SiteCl132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA132 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd132 : (PRE_first_tail_x15_r0_body.clo132 ++ PRE_first_tail_x15_r0_body.cln132 ++ PRE_first_tail_x15_r0_body.cli132).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle132 : Conv.Cnt.leB (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck132 : Conv.ncleanListB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.cli132 = true
theorem PRE_first_tail_x15_r0_body.cncl132 (h : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) : Conv.NClean (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle132 PRE_first_tail_x15_r0_body.ckA132 PRE_first_tail_x15_r0_body.cobjsK132 PRE_first_tail_x15_r0_body.cnodesK132 PRE_first_tail_x15_r0_body.citemsK132 PRE_first_tail_x15_r0_body.cbd132 PRE_first_tail_x15_r0_body.cck132

end Host.Load.Run.Tpl
end

section -- SiteS132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 132 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc132 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P132 : LoadP := PRE_first_tail_x15_r0_body.Pc132.raise 17912
kernel_rfl PRE_first_tail_x15_r0_body.craise132 : Nat.ble PRE_first_tail_x15_r0_body.Pc132.N0 17912 = true
theorem PRE_first_tail_x15_r0_body.raised132 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc132 PRE_first_tail_x15_r0_body.P132 :=
  .inr ⟨17912, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise132, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_132 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_132 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi)
def PRE_first_tail_x15_r0_body.khinv132 : PTrie Nat := Stage.setAll PTrie.nil [(20838, 20812), (20816, 20813), (20839, 20814)]
def PRE_first_tail_x15_r0_body.kninv132 : PTrie Nat := Stage.setAll PTrie.nil [(17885, 17885), (17886, 17886), (17887, 17887), (17888, 17888), (17889, 17889), (17890, 17890), (17891, 17891), (17892, 17892), (17893, 17893), (17894, 17894), (17895, 17895), (17896, 17896), (17897, 17897), (17898, 17898), (17899, 17899), (17900, 17900), (17901, 17901), (17902, 17902), (17903, 17903), (17904, 17904), (17905, 17905), (17906, 17906), (17907, 17907), (17908, 17908), (17909, 17909), (17910, 17910), (17911, 17911)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS132 : List Nat := [20792, 20805, 20811, 20812, 20813, 20814, 20815, 20816, 20817, 20818, 20819, 20820, 20821, 20822, 20823, 20824, 20825, 20826, 20827, 20828, 20829, 20830, 20831, 20832, 20833, 20834, 20835, 20836, 20837, 20838, 20839]
def PRE_first_tail_x15_r0_body.cnS132 : List Nat := List.range' 17885 27
def PRE_first_tail_x15_r0_body.ciS132 : List Nat := [] ++ List.range' 17885 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0132 : PRE_first_tail_x15_r0_body.kd132.nh0 = PRE_first_tail_x15_r0_body.cx0_132.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1132 : PRE_first_tail_x15_r0_body.kd132.nh1 = PRE_first_tail_x15_r0_body.cx1_132.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0132 : PRE_first_tail_x15_r0_body.kd132.nn0 = PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1132 : PRE_first_tail_x15_r0_body.kd132.nn1 = PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo132 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P132.lo && Nat.ble PRE_first_tail_x15_r0_body.P132.lo PRE_first_tail_x15_r0_body.cx0_132.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P132.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P132.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt132 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_132.mlx.next PRE_first_tail_x15_r0_body.cx1_132.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband132 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P132.NL && Nat.ble PRE_first_tail_x15_r0_body.P132.NL PRE_first_tail_x15_r0_body.P132.N0 && Nat.ble PRE_first_tail_x15_r0_body.P132.N0 PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow132 : PRE_first_tail_x15_r0_body.kd132.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren132 : checkRenG PRE_first_tail_x15_r0_body.kd132.hnd PRE_first_tail_x15_r0_body.khinv132 (phB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband132 : PRE_first_tail_x15_r0_body.kd132.checkBand PRE_first_tail_x15_r0_body.P132.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos132 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd132.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren132 : checkRenG PRE_first_tail_x15_r0_body.kd132.node PRE_first_tail_x15_r0_body.kninv132 (pnB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P132.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd132.nodeF j) PRE_first_tail_x15_r0_body.cx1_132.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a132 : PRE_first_tail_x15_r0_body.cx0_132.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b132 : PRE_first_tail_x15_r0_body.cx0_132.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.pending = PRE_first_tail_x15_r0_body.cx0_132.mlx.pending.map PRE_first_tail_x15_r0_body.kappa132.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.errh = PRE_first_tail_x15_r0_body.cx0_132.mlx.errh.map PRE_first_tail_x15_r0_body.kappa132.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.files = PRE_first_tail_x15_r0_body.cx0_132.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.arch = PRE_first_tail_x15_r0_body.cx0_132.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_132.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.wired = PRE_first_tail_x15_r0_body.cx0_132.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost132 : PRE_first_tail_x15_r0_body.cx1_132.host = PRE_first_tail_x15_r0_body.cx0_132.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd132`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0132 : PRE_first_tail_x15_r0_body.kd132.n0 = 2779041
kernel_rfl PRE_first_tail_x15_r0_body.ckn1132 : PRE_first_tail_x15_r0_body.kd132.n1 = 2780190
kernel_rfl PRE_first_tail_x15_r0_body.ckheap132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.heap).all (fun x => Nat.ble 2779035 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl132 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd132.heap.get (2779035 + j) = nth? PRE_first_tail_x15_r0_body.pl132 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja132 : Nat.ble 2779035 2779035 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn132 : Nat.ble 5726 5726 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD132 : Nat.ble 2779035 PRE_first_tail_x15_r0_body.kd132.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn132 : Nat.ble 20812 PRE_first_tail_x15_r0_body.kd132.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn132 : Nat.ble 17885 PRE_first_tail_x15_r0_body.kd132.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb132 : Nat.ble 20812 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.heap).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.hnd).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (Nat.ble (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix132 : Conv.FixOld (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa132 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn132) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb132) PRE_first_tail_x15_r0_body.fheap132 PRE_first_tail_x15_r0_body.fhnd132 PRE_first_tail_x15_r0_body.fnode132
kernel_rfl PRE_first_tail_x15_r0_body.fcxn132 : (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn132 : (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0132 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_132.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_132.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I132 : PRE_first_tail_x15_r0_body.cx1_132.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS132.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd132 : (PRE_first_tail_x15_r0_body.clo132 ++ PRE_first_tail_x15_r0_body.cln132 ++ PRE_first_tail_x15_r0_body.cli132 ++ PRE_first_tail_x15_r0_body.cwS132 ++ PRE_first_tail_x15_r0_body.cnS132 ++ PRE_first_tail_x15_r0_body.ciS132).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW132 : PRE_first_tail_x15_r0_body.cwS132.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo132.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI132 : PRE_first_tail_x15_r0_body.ciS132.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli132.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN132 : PRE_first_tail_x15_r0_body.cnS132.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF132 : PRE_first_tail_x15_r0_body.cln132.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh132 : PRE_first_tail_x15_r0_body.clo132.all (handleOK PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132.lo PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo132 : PRE_first_tail_x15_r0_body.clo132.map (fun h => PRE_first_tail_x15_r0_body.cx1_132.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa132.handle h)) = PRE_first_tail_x15_r0_body.clo132.map (fun h => (PRE_first_tail_x15_r0_body.cx0_132.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa132.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok132 : PRE_first_tail_x15_r0_body.clo132.all (objOK PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132.NL PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd132 : PRE_first_tail_x15_r0_body.cln132.all (nodeOKF PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.P132 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp132 : ((PRE_first_tail_x15_r0_body.cln132.filter (fullB PRE_first_tail_x15_r0_body.P132))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_132.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa132.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln132.filter (fullB PRE_first_tail_x15_r0_body.P132))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_132.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa132.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI132 : incrB PRE_first_tail_x15_r0_body.kd132.nodeF (List.range' 17885 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK132 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all (fun k => Nat.ble 17885 k && Nat.blt k 17912) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL132 : (PRE_first_tail_x15_r0_body.cln132.filter (Nat.ble PRE_first_tail_x15_r0_body.P132.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd132.nodeF i) && (Nat.blt i 17912 || Nat.ble PRE_first_tail_x15_r0_body.kd132.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord132 : (PRE_first_tail_x15_r0_body.cln132.filter (Nat.ble PRE_first_tail_x15_r0_body.P132.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd132.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd132.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd132.nodeF j) (PRE_first_tail_x15_r0_body.kd132.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow132 PRE_first_tail_x15_r0_body.cnn1132 PRE_first_tail_x15_r0_body.fnordI132 PRE_first_tail_x15_r0_body.fnordK132 PRE_first_tail_x15_r0_body.fnordL132
kernel_rfl PRE_first_tail_x15_r0_body.fi132 : PRE_first_tail_x15_r0_body.cli132.all (pnB PRE_first_tail_x15_r0_body.cx0_132.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii132 : PRE_first_tail_x15_r0_body.cli132.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_132.mlx.items.get (PRE_first_tail_x15_r0_body.kappa132.node k) = (PRE_first_tail_x15_r0_body.cx0_132.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa132.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.kd132 PRE_first_tail_x15_r0_body.khinv132 PRE_first_tail_x15_r0_body.kninv132 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.cx1_132.mlx (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo132 PRE_first_tail_x15_r0_body.cln132 PRE_first_tail_x15_r0_body.cli132 PRE_first_tail_x15_r0_body.cwS132 PRE_first_tail_x15_r0_body.cnS132 PRE_first_tail_x15_r0_body.ciS132 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0132, PRE_first_tail_x15_r0_body.cnh1132, PRE_first_tail_x15_r0_body.cnn0132, PRE_first_tail_x15_r0_body.cnn1132, PRE_first_tail_x15_r0_body.cplo132, PRE_first_tail_x15_r0_body.ccnt132, PRE_first_tail_x15_r0_body.cnband132, PRE_first_tail_x15_r0_body.chbelow132, PRE_first_tail_x15_r0_body.chren132, PRE_first_tail_x15_r0_body.cband132, PRE_first_tail_x15_r0_body.cnh1pos132, PRE_first_tail_x15_r0_body.cnren132, PRE_first_tail_x15_r0_body.cnlow132, PRE_first_tail_x15_r0_body.cabs0a132, PRE_first_tail_x15_r0_body.cabs0b132, PRE_first_tail_x15_r0_body.ctok1132, PRE_first_tail_x15_r0_body.cpend132, PRE_first_tail_x15_r0_body.cerrh132, PRE_first_tail_x15_r0_body.cfiles132, PRE_first_tail_x15_r0_body.carch132, PRE_first_tail_x15_r0_body.csizes132, PRE_first_tail_x15_r0_body.cwired132, PRE_first_tail_x15_r0_body.cfix132, clean, PRE_first_tail_x15_r0_body.fcxn132, PRE_first_tail_x15_r0_body.fcnn132, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0132, PRE_first_tail_x15_r0_body.fnk132, PRE_first_tail_x15_r0_body.ckA132, PRE_first_tail_x15_r0_body.cobjsK132, PRE_first_tail_x15_r0_body.cnodesK132, PRE_first_tail_x15_r0_body.citemsK132, PRE_first_tail_x15_r0_body.f1A132, PRE_first_tail_x15_r0_body.f1O132, PRE_first_tail_x15_r0_body.f1N132, PRE_first_tail_x15_r0_body.f1I132, PRE_first_tail_x15_r0_body.fbd132, PRE_first_tail_x15_r0_body.fincW132, PRE_first_tail_x15_r0_body.fincI132, PRE_first_tail_x15_r0_body.fincN132, PRE_first_tail_x15_r0_body.flnF132, PRE_first_tail_x15_r0_body.fh132, PRE_first_tail_x15_r0_body.fo132, PRE_first_tail_x15_r0_body.fok132, PRE_first_tail_x15_r0_body.fnd132, PRE_first_tail_x15_r0_body.fp132, PRE_first_tail_x15_r0_body.fnord132, PRE_first_tail_x15_r0_body.fi132, PRE_first_tail_x15_r0_body.fii132⟩
theorem PRE_first_tail_x15_r0_body.cnshift132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx) : NShift PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.cx0_132 PRE_first_tail_x15_r0_body.cx1_132 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost132 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0132 PRE_first_tail_x15_r0_body.ckn1132 PRE_first_tail_x15_r0_body.ckheap132 PRE_first_tail_x15_r0_body.ckpl132)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.fxC_132
kernel_rfl PRE_first_tail_x15_r0_body.okrC_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1281.ffi) = some PRE_first_tail_x15_r0_body.krC_132
noncomputable def PRE_first_tail_x15_r0_body.fx0_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.fx0_132
kernel_rfl PRE_first_tail_x15_r0_body.okr0_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1283.ffi) = some PRE_first_tail_x15_r0_body.kr0_132
noncomputable def PRE_first_tail_x15_r0_body.fx1_132 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_132 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_132 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.fx1_132
kernel_rfl PRE_first_tail_x15_r0_body.okr1_132 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1282.ffi) = some PRE_first_tail_x15_r0_body.kr1_132
kernel_rfl PRE_first_tail_x15_r0_body.ff0132 : PRE_first_tail_x15_r0_body.fx0_132 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_132 (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_132.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1132 : PRE_first_tail_x15_r0_body.fx1_132 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_132 (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_132.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck132 : freedLB PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.fx0_132 PRE_first_tail_x15_r0_body.fx1_132 PRE_first_tail_x15_r0_body.clo132 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0132 : PRE_first_tail_x15_r0_body.kr0_132.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.flags (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_132.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0132 : PRE_first_tail_x15_r0_body.kr0_132.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.targs (PRE_first_tail_x15_r0_body.clo132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_132.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1132 : PRE_first_tail_x15_r0_body.kr1_132.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.flags (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_132.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1132 : PRE_first_tail_x15_r0_body.kr1_132.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_132.targs (PRE_first_tail_x15_r0_body.cwS132.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_132.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck132 : krecLB PRE_first_tail_x15_r0_body.kappa132 5744 PRE_first_tail_x15_r0_body.cx0_132.mlx PRE_first_tail_x15_r0_body.kr0_132 PRE_first_tail_x15_r0_body.kr1_132 PRE_first_tail_x15_r0_body.clo132 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn132 : Nat.ble 5726 5744 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge132 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1282.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR132 : pendRegB PRE_first_tail_x15_r0_body.kappa132 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe132 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1283.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1282.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift132 (clean : Conv.NClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P132.NL) (cl : SSt (· < 5744) PRE_first_tail_x15_r0_body.cx0_132.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_132.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_132.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_132.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1281.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_132.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P132 5744 PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1283.ffi PRE_first_tail_x15_r0_body.s1282.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift132 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue132, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp132 t ht),
    PRE_first_tail_x15_r0_body.cbridge132,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_132 PRE_first_tail_x15_r0_body.ofx1_132 hobjC PRE_first_tail_x15_r0_body.ff0132 PRE_first_tail_x15_r0_body.ff1132 PRE_first_tail_x15_r0_body.ffck132,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1283.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1282.ffi) (PRE_first_tail_x15_r0_body.cfoot132 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_132 PRE_first_tail_x15_r0_body.okr1_132 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn132) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0132 PRE_first_tail_x15_r0_body.fkt0132 PRE_first_tail_x15_r0_body.fkf1132 PRE_first_tail_x15_r0_body.fkt1132 PRE_first_tail_x15_r0_body.fkck132,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0132 PRE_first_tail_x15_r0_body.cnh1132 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe132) PRE_first_tail_x15_r0_body.cpendR132⟩

end Host.Load.Run.Tpl
end

section -- st132/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st132 0
host_stream_state PRE_first_tail_x15_r0_body.st132 1
host_stream_state PRE_first_tail_x15_r0_body.st132 2
host_stream_state PRE_first_tail_x15_r0_body.st132 3
host_stream_state PRE_first_tail_x15_r0_body.st132 4
host_stream_state PRE_first_tail_x15_r0_body.st132 5
end Host.Load.Run.Tpl
end

section -- Site132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 132 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g132__g133` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1281`, the merged state `PRE_first_tail_x15_r0_body.s1282`,
the site template `PRE_first_tail_x15_r0_body.st132` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1283`: the merge.
The footprint's facts are in `SiteF132`, the compaction's in `SiteC132`, `SiteK132`, `SiteNa132`, `SiteNb132`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso132 : PRE_first_tail_x15_r0_body.st132.s0 = { PRE_first_tail_x15_r0_body.s1281 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs132 : List Frame := PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_132 : PRE_first_tail_x15_r0_body.S1281.tab.length = 5726
kernel_rfl PRE_first_tail_x15_r0_body.tab0_132 : PRE_first_tail_x15_r0_body.st132.S0.tab = PRE_first_tail_x15_r0_body.S1281.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws132 : List Nat := [3189, 3190, 3191, 3192, 3193, 3194, 3195, 3196, 3197, 3198, 3199, 3200, 3201, 3202, 3203, 3204, 3205, 3206, 3207, 3208, 3209, 3210, 3211, 3212, 3213, 3214, 3215, 3216, 3217, 3218, 3219]
kernel_rfl PRE_first_tail_x15_r0_body.fresh132 : (PRE_first_tail_x15_r0_body.S1281.tab.all fun e => PRE_first_tail_x15_r0_body.ws132.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1281.oracle.all fun q => PRE_first_tail_x15_r0_body.ws132.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab132 : PRE_first_tail_x15_r0_body.S1282.tab = PRE_first_tail_x15_r0_body.S1281.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws132
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen132 : PRE_first_tail_x15_r0_body.st132.S5.tab.length - PRE_first_tail_x15_r0_body.st132.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged132`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap132 : PRE_first_tail_x15_r0_body.s1282.heap = PRE_first_tail_x15_r0_body.st132.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext132 : PRE_first_tail_x15_r0_body.s1282.next = PRE_first_tail_x15_r0_body.st132.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl132 : PRE_first_tail_x15_r0_body.s1282.ctl = PRE_first_tail_x15_r0_body.st132.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack132 : PRE_first_tail_x15_r0_body.s1282.stack = PRE_first_tail_x15_r0_body.st132.s5.stack ++ PRE_first_tail_x15_r0_body.s1281.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs132 : PRE_first_tail_x15_r0_body.s1282.jobs = PRE_first_tail_x15_r0_body.st132.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi132 : PRE_first_tail_x15_r0_body.s1282.ffi = PRE_first_tail_x15_r0_body.st132.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace132 : PRE_first_tail_x15_r0_body.s1282.trace = PRE_first_tail_x15_r0_body.st132.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores132 : PRE_first_tail_x15_r0_body.s1282.stores = PRE_first_tail_x15_r0_body.st132.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 132 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived132 : PRE_first_tail_x15_r0_body.nr132.map (fun r => nth? PRE_first_tail_x15_r0_body.st132.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo132 : PRE_first_tail_x15_r0_body.nr132.all (Nat.ble 5726) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj132 : PRE_first_tail_x15_r0_body.cws132.all (fun c => !PRE_first_tail_x15_r0_body.ws132.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ132 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws132 PRE_first_tail_x15_r0_body.crs132 PRE_first_tail_x15_r0_body.ws132

end Host.Load.Run.Tpl
end

section -- st132/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st132`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st132.wrR : List (Nat × Nat) := [(2672641, 2672642), (2778209, 2778210), (2778754, 2778755), (2779010, 2779011)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st132.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st132.s5.heap PRE_first_tail_x15_r0_body.st132.wrR ++ freshOf PRE_first_tail_x15_r0_body.st132.s5.heap PRE_first_tail_x15_r0_body.st132.s0.next PRE_first_tail_x15_r0_body.st132.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st132.wr : List Nat := PRE_first_tail_x15_r0_body.st132.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st132.heapFoot : PRE_first_tail_x15_r0_body.st132.s5.heap = setAll PRE_first_tail_x15_r0_body.st132.s0.heap PRE_first_tail_x15_r0_body.st132.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st132.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st132.s0.next PRE_first_tail_x15_r0_body.st132.s5.next = true
theorem PRE_first_tail_x15_r0_body.st132.grows : PRE_first_tail_x15_r0_body.st132.s0.next ≤ PRE_first_tail_x15_r0_body.st132.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st132.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st132.wh : List Nat := [20792, 20805, 20811, 20812, 20813, 20814, 20815, 20816, 20817, 20818, 20819, 20820, 20821, 20822, 20823, 20824, 20825, 20826, 20827, 20828, 20829, 20830, 20831, 20832, 20833, 20834, 20835, 20836, 20837, 20838, 20839]
def PRE_first_tail_x15_r0_body.st132.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st132.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st132.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st132.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st132.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st132.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st132.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st132.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st132.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st132.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 132 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB132 : nodupT PRE_first_tail_x15_r0_body.st132.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup132 : PRE_first_tail_x15_r0_body.st132.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB132).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB132 : PRE_first_tail_x15_r0_body.st132.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound132 : ∀ b ∈ PRE_first_tail_x15_r0_body.st132.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB132 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr132 := PRE_first_tail_x15_r0_body.st132.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq132 : PRE_first_tail_x15_r0_body.st132.s5.trace = PRE_first_tail_x15_r0_body.trFr132 ++ PRE_first_tail_x15_r0_body.st132.s0.trace
theorem PRE_first_tail_x15_r0_body.trace132 : ∃ fr, PRE_first_tail_x15_r0_body.st132.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st132.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq132⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide132 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB132 : (PRE_first_tail_x15_r0_body.wide132.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st132.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix132 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide132, WFix Map.id (Present PRE_first_tail_x15_r0_body.st132.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB132 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 132 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1282`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO132 : PRE_first_tail_x15_r0_body.st132.S0.oracle = PRE_first_tail_x15_r0_body.st132.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B132 : PRE_first_tail_x15_r0_body.st132.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st132.s0.next || (PRE_first_tail_x15_r0_body.st132.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot132 : Conv.StageFoot PRE_first_tail_x15_r0_body.st132.wr PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st132.heapFoot PRE_first_tail_x15_r0_body.wrNodup132 PRE_first_tail_x15_r0_body.wrBound132 PRE_first_tail_x15_r0_body.wr0B132 PRE_first_tail_x15_r0_body.st132.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged132 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st132.F.S → PRE_first_tail_x15_r0_body.st132.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st132.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st132.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs132 PRE_first_tail_x15_r0_body.st132.wr PRE_first_tail_x15_r0_body.s1281 PRE_first_tail_x15_r0_body.st132.s5 PRE_first_tail_x15_r0_body.st132.s0
      PRE_first_tail_x15_r0_body.st132.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st132.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1282 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso132 PRE_first_tail_x15_r0_body.stFoot132 PRE_first_tail_x15_r0_body.wrNodup132 PRE_first_tail_x15_r0_body.wrBound132 PRE_first_tail_x15_r0_body.trace132 PRE_first_tail_x15_r0_body.mheap132
    PRE_first_tail_x15_r0_body.mnext132 PRE_first_tail_x15_r0_body.mctl132 PRE_first_tail_x15_r0_body.mstack132 PRE_first_tail_x15_r0_body.mjobs132 PRE_first_tail_x15_r0_body.mffi132 PRE_first_tail_x15_r0_body.mtrace132 PRE_first_tail_x15_r0_body.mstores132 h

def PRE_first_tail_x15_r0_body.arrEl132_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE132_2665 : arrOf PRE_first_tail_x15_r0_body.s1282 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl132_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA132_2665 : isArrB PRE_first_tail_x15_r0_body.s1282 2665 = true
theorem PRE_first_tail_x15_r0_body.arr132_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1282.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl132_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE132_2665 PRE_first_tail_x15_r0_body.arrA132_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN132_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl132_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR132_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl132_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN132_2665

def PRE_first_tail_x15_r0_body.arrEl132_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE132_2673467 : arrOf PRE_first_tail_x15_r0_body.s1282 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl132_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA132_2673467 : isArrB PRE_first_tail_x15_r0_body.s1282 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr132_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1282.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl132_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE132_2673467 PRE_first_tail_x15_r0_body.arrA132_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN132_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl132_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR132_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl132_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN132_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k132 : isArrB PRE_first_tail_x15_r0_body.s1282 4910 = false
theorem PRE_first_tail_x15_r0_body.keep132 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1282 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k132 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr132_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl132_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ132
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 132 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1281`, the merged
state `PRE_first_tail_x15_r0_body.s1282`, the canonical state `PRE_first_tail_x15_r0_body.s1283`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl132 : PRE_first_tail_x15_r0_body.pl132.all (Nat.ble PRE_first_tail_x15_r0_body.s1281.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd132 : nodupT PRE_first_tail_x15_r0_body.pl132 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1132 : Nat.ble PRE_first_tail_x15_r0_body.s1281.next 2780190 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst132 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1281.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn132 : PRE_first_tail_x15_r0_body.s1283.next = PRE_first_tail_x15_r0_body.s1281.next + PRE_first_tail_x15_r0_body.pl132.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn132 : PRE_first_tail_x15_r0_body.s1282.next = 2780190
kernel_rfl PRE_first_tail_x15_r0_body.zgrow132 : Nat.ble PRE_first_tail_x15_r0_body.s1283.next PRE_first_tail_x15_r0_body.s1282.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh132 : PRE_first_tail_x15_r0_body.S1281.tab.all (fun e => PRE_first_tail_x15_r0_body.cws132.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd132 : nodupT PRE_first_tail_x15_r0_body.cws132 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi132 : PRE_first_tail_x15_r0_body.nr132.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1282.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt132 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1281.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg132_2665 : PRE_first_tail_x15_r0_body.s1283.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1283 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk132_2665 : (objOf PRE_first_tail_x15_r0_body.s1283 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm132_2665 : PRE_first_tail_x15_r0_body.s1282.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa132.obj (objOf PRE_first_tail_x15_r0_body.s1283 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1282 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg132_2673467 : PRE_first_tail_x15_r0_body.s1283.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1283 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk132_2673467 : (objOf PRE_first_tail_x15_r0_body.s1283 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm132_2673467 : PRE_first_tail_x15_r0_body.s1282.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa132.obj (objOf PRE_first_tail_x15_r0_body.s1283 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1282 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw132_4910 : (PRE_first_tail_x15_r0_body.s1283.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw132_2673472 : (PRE_first_tail_x15_r0_body.s1283.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw132_2673473 : (PRE_first_tail_x15_r0_body.s1283.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd132 : PRE_first_tail_x15_r0_body.cl132.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr132 : PRE_first_tail_x15_r0_body.st132.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1281.next || PRE_first_tail_x15_r0_body.cl132.contains b) = true
def PRE_first_tail_x15_r0_body.zl132 : List Nat := PRE_first_tail_x15_r0_body.cl132.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE132 : PRE_first_tail_x15_r0_body.zl132.map (fun a => PRE_first_tail_x15_r0_body.s1282.heap.get (PRE_first_tail_x15_r0_body.kappa132.a a)) = PRE_first_tail_x15_r0_body.zl132.map (fun a => (PRE_first_tail_x15_r0_body.s1283.heap.get a).map PRE_first_tail_x15_r0_body.kappa132.hobj)
theorem PRE_first_tail_x15_r0_body.zimg132 : HeapImg PRE_first_tail_x15_r0_body.kappa132 PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.s1282 PRE_first_tail_x15_r0_body.zl132 := PRE_first_tail_x15_r0_body.zimgE132
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl132 : PRE_first_tail_x15_r0_body.s1282.ctl = PRE_first_tail_x15_r0_body.kappa132.ctl PRE_first_tail_x15_r0_body.s1283.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack132 : PRE_first_tail_x15_r0_body.s1282.stack = PRE_first_tail_x15_r0_body.s1283.stack.map PRE_first_tail_x15_r0_body.kappa132.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs132 : PRE_first_tail_x15_r0_body.s1282.jobs = PRE_first_tail_x15_r0_body.s1283.jobs.map PRE_first_tail_x15_r0_body.kappa132.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores132 : PRE_first_tail_x15_r0_body.s1282.stores = PRE_first_tail_x15_r0_body.kappa132.stores PRE_first_tail_x15_r0_body.s1283.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots132 : checkRootsSupp PRE_first_tail_x15_r0_body.s1283 5744 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC132 : PRE_first_tail_x15_r0_body.S1281.tab.length + PRE_first_tail_x15_r0_body.cws132.length = 5744
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap132 : PRE_first_tail_x15_r0_body.kappa132 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1281.next 2780190 PRE_first_tail_x15_r0_body.S1281.tab.length PRE_first_tail_x15_r0_body.pl132 (PRE_first_tail_x15_r0_body.nr132.map NumV.ref) PRE_first_tail_x15_r0_body.kd132.big
  PRE_first_tail_x15_r0_body.kd132.region PRE_first_tail_x15_r0_body.kd132.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin132 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1283.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc132 : Conv.jcleanListB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.cl132 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB132 : noBigRootsP (fun i => !Conv.oldBigB (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1283.trace PRE_first_tail_x15_r0_body.s1283 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm132 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17885 = true
theorem PRE_first_tail_x15_r0_body.cjcl132 (h : Conv.JClean (⟨20812, 17885, 2779035, 5726⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1281) : Conv.JClean (⟨20815, 17912, 2779041, 5744⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1283 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle132)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap132 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd132 a ha)) PRE_first_tail_x15_r0_body.zjc132

end Host.Load.Run.Tpl
end

section -- st132/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st132.bodyLast from PRE_first_tail_x15_r0_body.st132.s4 to PRE_first_tail_x15_r0_body.st132.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st132.F PRE_first_tail_x15_r0_body.st132.s4).run PRE_first_tail_x15_r0_body.st132.S4 = some (PRE_first_tail_x15_r0_body.st132.s5, PRE_first_tail_x15_r0_body.st132.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st132.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st132.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st132.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st132.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st132/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st132.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st132.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st132.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st132.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st132.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st132.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st132.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st132.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st132.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st132.s4 PRE_first_tail_x15_r0_body.st132.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st132/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st132.bodyK0F from PRE_first_tail_x15_r0_body.st132.s0 to PRE_first_tail_x15_r0_body.st132.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 0).getD 0) PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s1, PRE_first_tail_x15_r0_body.st132.S1)
theorem PRE_first_tail_x15_r0_body.st132.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 0).getD 0) PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s1, PRE_first_tail_x15_r0_body.st132.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st132.bodyOkLN_ok PRE_first_tail_x15_r0_body.st132.bodyK0F
end Host.Load.Run.Tpl
end

section -- st132/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st132.bodyK1F from PRE_first_tail_x15_r0_body.st132.s1 to PRE_first_tail_x15_r0_body.st132.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 1).getD 0) PRE_first_tail_x15_r0_body.st132.s1 PRE_first_tail_x15_r0_body.st132.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s2, PRE_first_tail_x15_r0_body.st132.S2)
theorem PRE_first_tail_x15_r0_body.st132.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 1).getD 0) PRE_first_tail_x15_r0_body.st132.s1 PRE_first_tail_x15_r0_body.st132.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s2, PRE_first_tail_x15_r0_body.st132.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st132.bodyOkLN_ok PRE_first_tail_x15_r0_body.st132.bodyK1F
end Host.Load.Run.Tpl
end

section -- st132/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st132.bodyK2F from PRE_first_tail_x15_r0_body.st132.s2 to PRE_first_tail_x15_r0_body.st132.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 2).getD 0) PRE_first_tail_x15_r0_body.st132.s2 PRE_first_tail_x15_r0_body.st132.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s3, PRE_first_tail_x15_r0_body.st132.S3)
theorem PRE_first_tail_x15_r0_body.st132.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 2).getD 0) PRE_first_tail_x15_r0_body.st132.s2 PRE_first_tail_x15_r0_body.st132.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s3, PRE_first_tail_x15_r0_body.st132.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st132.bodyOkLN_ok PRE_first_tail_x15_r0_body.st132.bodyK2F
end Host.Load.Run.Tpl
end

section -- st132/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st132.bodyK3F from PRE_first_tail_x15_r0_body.st132.s3 to PRE_first_tail_x15_r0_body.st132.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 3).getD 0) PRE_first_tail_x15_r0_body.st132.s3 PRE_first_tail_x15_r0_body.st132.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s4, PRE_first_tail_x15_r0_body.st132.S4)
theorem PRE_first_tail_x15_r0_body.st132.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st132.ks 3).getD 0) PRE_first_tail_x15_r0_body.st132.s3 PRE_first_tail_x15_r0_body.st132.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st132.s4, PRE_first_tail_x15_r0_body.st132.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st132.bodyOkLN_ok PRE_first_tail_x15_r0_body.st132.bodyK3F
end Host.Load.Run.Tpl
end

section -- st132/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st132.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.S0 = some (PRE_first_tail_x15_r0_body.st132.s4, PRE_first_tail_x15_r0_body.st132.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st132.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st132.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st132.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st132.ks 3).getD 0) PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.s3 PRE_first_tail_x15_r0_body.st132.s4 PRE_first_tail_x15_r0_body.st132.S0 PRE_first_tail_x15_r0_body.st132.S3 PRE_first_tail_x15_r0_body.st132.S4 (runOk_trans PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st132.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st132.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st132.ks 2).getD 0) PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.s2 PRE_first_tail_x15_r0_body.st132.s3 PRE_first_tail_x15_r0_body.st132.S0 PRE_first_tail_x15_r0_body.st132.S2 PRE_first_tail_x15_r0_body.st132.S3 (runOk_trans PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st132.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st132.ks 1).getD 0) PRE_first_tail_x15_r0_body.st132.s0 PRE_first_tail_x15_r0_body.st132.s1 PRE_first_tail_x15_r0_body.st132.s2 PRE_first_tail_x15_r0_body.st132.S0 PRE_first_tail_x15_r0_body.st132.S1 PRE_first_tail_x15_r0_body.st132.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st132.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st132.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st132.F (PRE_first_tail_x15_r0_body.st132.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st132.s0
  S0 := PRE_first_tail_x15_r0_body.st132.S0
  s1 := PRE_first_tail_x15_r0_body.st132.s4
  S1 := PRE_first_tail_x15_r0_body.st132.S4
  s2 := PRE_first_tail_x15_r0_body.st132.s5
  S2 := PRE_first_tail_x15_r0_body.st132.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st132.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st132.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st132.bodyHalt
  last := PRE_first_tail_x15_r0_body.st132.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st132.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 133 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1291` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa133` into the merged state
`PRE_first_tail_x15_r0_body.s1290`. -/

def PRE_first_tail_x15_r0_body.pl133 : List Nat := []
def PRE_first_tail_x15_r0_body.nr133 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd133 : RData :=
  ⟨2779531, 2779533, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20828, 20828, 17925, 17925, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa133 : Map :=
  Conv.Map.compact 2779531 2779533 5765 PRE_first_tail_x15_r0_body.pl133 (PRE_first_tail_x15_r0_body.nr133.map NumV.ref) PRE_first_tail_x15_r0_body.kd133.big
    PRE_first_tail_x15_r0_body.kd133.region PRE_first_tail_x15_r0_body.kd133.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws133 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs133 : List SymE := PRE_first_tail_x15_r0_body.nr133.map fun r => (nth? PRE_first_tail_x15_r0_body.S1290.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta133 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws133 PRE_first_tail_x15_r0_body.crs133
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB133 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab133 : PRE_first_tail_x15_r0_body.S1291.tab = PRE_first_tail_x15_r0_body.S1289.tab ++ PRE_first_tail_x15_r0_body.cws133.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace133 : PRE_first_tail_x15_r0_body.s1291.trace = PRE_first_tail_x15_r0_body.s1289.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext133 : PRE_first_tail_x15_r0_body.s1291.next = 2779531
kernel_rfl PRE_first_tail_x15_r0_body.ccounters133 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.nnext) = (20828, 17925)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1290.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa133.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.tokens.all (bSN 5765) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean133 : Conv.cleanListB 20828 131072 (fun r => Nat.ble 83312 r) PRE_first_tail_x15_r0_body.s1291
    (PRE_first_tail_x15_r0_body.wrB133 ++ (List.range 0).map (2779531 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs133 : bigsOutB 20828 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl133`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl133 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo133 : List Nat := []
def PRE_first_tail_x15_r0_body.cln133 : List Nat := []
def PRE_first_tail_x15_r0_body.cli133 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap133 : PRE_first_tail_x15_r0_body.s1291.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1289.heap (PRE_first_tail_x15_r0_body.cl133.filterMap fun a => (PRE_first_tail_x15_r0_body.s1291.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe133 : Nat.ble PRE_first_tail_x15_r0_body.s1289.next PRE_first_tail_x15_r0_body.s1291.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP133 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp133 : Conv.suppListB PRE_first_tail_x15_r0_body.s1291 5765 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound133 : Conv.boundListB PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst133 : Conv.sstListB 5765 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx PRE_first_tail_x15_r0_body.cln133 PRE_first_tail_x15_r0_body.clo133 PRE_first_tail_x15_r0_body.cli133 = true

end Host.Load.Run.Tpl
end

section -- SiteCl133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA133 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd133 : (PRE_first_tail_x15_r0_body.clo133 ++ PRE_first_tail_x15_r0_body.cln133 ++ PRE_first_tail_x15_r0_body.cli133).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle133 : Conv.Cnt.leB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck133 : Conv.ncleanListB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx PRE_first_tail_x15_r0_body.clo133 PRE_first_tail_x15_r0_body.cln133 PRE_first_tail_x15_r0_body.cli133 = true
theorem PRE_first_tail_x15_r0_body.cncl133 (h : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle133 PRE_first_tail_x15_r0_body.ckA133 PRE_first_tail_x15_r0_body.cobjsK133 PRE_first_tail_x15_r0_body.cnodesK133 PRE_first_tail_x15_r0_body.citemsK133 PRE_first_tail_x15_r0_body.cbd133 PRE_first_tail_x15_r0_body.cck133

end Host.Load.Run.Tpl
end

section -- SiteS133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 133 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc133 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P133 : LoadP := PRE_first_tail_x15_r0_body.Pc133.raise 17925
kernel_rfl PRE_first_tail_x15_r0_body.craise133 : Nat.ble PRE_first_tail_x15_r0_body.Pc133.N0 17925 = true
theorem PRE_first_tail_x15_r0_body.raised133 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc133 PRE_first_tail_x15_r0_body.P133 :=
  .inr ⟨17925, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise133, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_133 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_133 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1290.ffi)
def PRE_first_tail_x15_r0_body.khinv133 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv133 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS133 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS133 : List Nat := List.range' 17925 0
def PRE_first_tail_x15_r0_body.ciS133 : List Nat := [] ++ List.range' 17925 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0133 : PRE_first_tail_x15_r0_body.kd133.nh0 = PRE_first_tail_x15_r0_body.cx0_133.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1133 : PRE_first_tail_x15_r0_body.kd133.nh1 = PRE_first_tail_x15_r0_body.cx1_133.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0133 : PRE_first_tail_x15_r0_body.kd133.nn0 = PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1133 : PRE_first_tail_x15_r0_body.kd133.nn1 = PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo133 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P133.lo && Nat.ble PRE_first_tail_x15_r0_body.P133.lo PRE_first_tail_x15_r0_body.cx0_133.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P133.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P133.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt133 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_133.mlx.next PRE_first_tail_x15_r0_body.cx1_133.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband133 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P133.NL && Nat.ble PRE_first_tail_x15_r0_body.P133.NL PRE_first_tail_x15_r0_body.P133.N0 && Nat.ble PRE_first_tail_x15_r0_body.P133.N0 PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow133 : PRE_first_tail_x15_r0_body.kd133.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren133 : checkRenG PRE_first_tail_x15_r0_body.kd133.hnd PRE_first_tail_x15_r0_body.khinv133 (phB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband133 : PRE_first_tail_x15_r0_body.kd133.checkBand PRE_first_tail_x15_r0_body.P133.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos133 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd133.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren133 : checkRenG PRE_first_tail_x15_r0_body.kd133.node PRE_first_tail_x15_r0_body.kninv133 (pnB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P133.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd133.nodeF j) PRE_first_tail_x15_r0_body.cx1_133.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a133 : PRE_first_tail_x15_r0_body.cx0_133.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b133 : PRE_first_tail_x15_r0_body.cx0_133.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.pending = PRE_first_tail_x15_r0_body.cx0_133.mlx.pending.map PRE_first_tail_x15_r0_body.kappa133.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.errh = PRE_first_tail_x15_r0_body.cx0_133.mlx.errh.map PRE_first_tail_x15_r0_body.kappa133.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.files = PRE_first_tail_x15_r0_body.cx0_133.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.arch = PRE_first_tail_x15_r0_body.cx0_133.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_133.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.wired = PRE_first_tail_x15_r0_body.cx0_133.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost133 : PRE_first_tail_x15_r0_body.cx1_133.host = PRE_first_tail_x15_r0_body.cx0_133.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd133`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0133 : PRE_first_tail_x15_r0_body.kd133.n0 = 2779531
kernel_rfl PRE_first_tail_x15_r0_body.ckn1133 : PRE_first_tail_x15_r0_body.kd133.n1 = 2779533
kernel_rfl PRE_first_tail_x15_r0_body.ckheap133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.heap).all (fun x => Nat.ble 2779531 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl133 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd133.heap.get (2779531 + j) = nth? PRE_first_tail_x15_r0_body.pl133 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja133 : Nat.ble 2779531 2779531 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn133 : Nat.ble 5765 5765 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD133 : Nat.ble 2779531 PRE_first_tail_x15_r0_body.kd133.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn133 : Nat.ble 20828 PRE_first_tail_x15_r0_body.kd133.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn133 : Nat.ble 17925 PRE_first_tail_x15_r0_body.kd133.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb133 : Nat.ble 20828 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.heap).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.hnd).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (Nat.ble (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix133 : Conv.FixOld (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa133 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn133) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb133) PRE_first_tail_x15_r0_body.fheap133 PRE_first_tail_x15_r0_body.fhnd133 PRE_first_tail_x15_r0_body.fnode133
kernel_rfl PRE_first_tail_x15_r0_body.fcxn133 : (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn133 : (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0133 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_133.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_133.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I133 : PRE_first_tail_x15_r0_body.cx1_133.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS133.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd133 : (PRE_first_tail_x15_r0_body.clo133 ++ PRE_first_tail_x15_r0_body.cln133 ++ PRE_first_tail_x15_r0_body.cli133 ++ PRE_first_tail_x15_r0_body.cwS133 ++ PRE_first_tail_x15_r0_body.cnS133 ++ PRE_first_tail_x15_r0_body.ciS133).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW133 : PRE_first_tail_x15_r0_body.cwS133.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo133.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI133 : PRE_first_tail_x15_r0_body.ciS133.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli133.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN133 : PRE_first_tail_x15_r0_body.cnS133.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF133 : PRE_first_tail_x15_r0_body.cln133.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh133 : PRE_first_tail_x15_r0_body.clo133.all (handleOK PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133.lo PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo133 : PRE_first_tail_x15_r0_body.clo133.map (fun h => PRE_first_tail_x15_r0_body.cx1_133.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa133.handle h)) = PRE_first_tail_x15_r0_body.clo133.map (fun h => (PRE_first_tail_x15_r0_body.cx0_133.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa133.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok133 : PRE_first_tail_x15_r0_body.clo133.all (objOK PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133.NL PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd133 : PRE_first_tail_x15_r0_body.cln133.all (nodeOKF PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.P133 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp133 : ((PRE_first_tail_x15_r0_body.cln133.filter (fullB PRE_first_tail_x15_r0_body.P133))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_133.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa133.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln133.filter (fullB PRE_first_tail_x15_r0_body.P133))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_133.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa133.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI133 : incrB PRE_first_tail_x15_r0_body.kd133.nodeF (List.range' 17925 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK133 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all (fun k => Nat.ble 17925 k && Nat.blt k 17925) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL133 : (PRE_first_tail_x15_r0_body.cln133.filter (Nat.ble PRE_first_tail_x15_r0_body.P133.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd133.nodeF i) && (Nat.blt i 17925 || Nat.ble PRE_first_tail_x15_r0_body.kd133.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord133 : (PRE_first_tail_x15_r0_body.cln133.filter (Nat.ble PRE_first_tail_x15_r0_body.P133.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd133.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd133.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd133.nodeF j) (PRE_first_tail_x15_r0_body.kd133.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow133 PRE_first_tail_x15_r0_body.cnn1133 PRE_first_tail_x15_r0_body.fnordI133 PRE_first_tail_x15_r0_body.fnordK133 PRE_first_tail_x15_r0_body.fnordL133
kernel_rfl PRE_first_tail_x15_r0_body.fi133 : PRE_first_tail_x15_r0_body.cli133.all (pnB PRE_first_tail_x15_r0_body.cx0_133.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii133 : PRE_first_tail_x15_r0_body.cli133.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_133.mlx.items.get (PRE_first_tail_x15_r0_body.kappa133.node k) = (PRE_first_tail_x15_r0_body.cx0_133.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa133.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.kd133 PRE_first_tail_x15_r0_body.khinv133 PRE_first_tail_x15_r0_body.kninv133 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.cx1_133.mlx (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo133 PRE_first_tail_x15_r0_body.cln133 PRE_first_tail_x15_r0_body.cli133 PRE_first_tail_x15_r0_body.cwS133 PRE_first_tail_x15_r0_body.cnS133 PRE_first_tail_x15_r0_body.ciS133 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0133, PRE_first_tail_x15_r0_body.cnh1133, PRE_first_tail_x15_r0_body.cnn0133, PRE_first_tail_x15_r0_body.cnn1133, PRE_first_tail_x15_r0_body.cplo133, PRE_first_tail_x15_r0_body.ccnt133, PRE_first_tail_x15_r0_body.cnband133, PRE_first_tail_x15_r0_body.chbelow133, PRE_first_tail_x15_r0_body.chren133, PRE_first_tail_x15_r0_body.cband133, PRE_first_tail_x15_r0_body.cnh1pos133, PRE_first_tail_x15_r0_body.cnren133, PRE_first_tail_x15_r0_body.cnlow133, PRE_first_tail_x15_r0_body.cabs0a133, PRE_first_tail_x15_r0_body.cabs0b133, PRE_first_tail_x15_r0_body.ctok1133, PRE_first_tail_x15_r0_body.cpend133, PRE_first_tail_x15_r0_body.cerrh133, PRE_first_tail_x15_r0_body.cfiles133, PRE_first_tail_x15_r0_body.carch133, PRE_first_tail_x15_r0_body.csizes133, PRE_first_tail_x15_r0_body.cwired133, PRE_first_tail_x15_r0_body.cfix133, clean, PRE_first_tail_x15_r0_body.fcxn133, PRE_first_tail_x15_r0_body.fcnn133, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0133, PRE_first_tail_x15_r0_body.fnk133, PRE_first_tail_x15_r0_body.ckA133, PRE_first_tail_x15_r0_body.cobjsK133, PRE_first_tail_x15_r0_body.cnodesK133, PRE_first_tail_x15_r0_body.citemsK133, PRE_first_tail_x15_r0_body.f1A133, PRE_first_tail_x15_r0_body.f1O133, PRE_first_tail_x15_r0_body.f1N133, PRE_first_tail_x15_r0_body.f1I133, PRE_first_tail_x15_r0_body.fbd133, PRE_first_tail_x15_r0_body.fincW133, PRE_first_tail_x15_r0_body.fincI133, PRE_first_tail_x15_r0_body.fincN133, PRE_first_tail_x15_r0_body.flnF133, PRE_first_tail_x15_r0_body.fh133, PRE_first_tail_x15_r0_body.fo133, PRE_first_tail_x15_r0_body.fok133, PRE_first_tail_x15_r0_body.fnd133, PRE_first_tail_x15_r0_body.fp133, PRE_first_tail_x15_r0_body.fnord133, PRE_first_tail_x15_r0_body.fi133, PRE_first_tail_x15_r0_body.fii133⟩
theorem PRE_first_tail_x15_r0_body.cnshift133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx) : NShift PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.cx0_133 PRE_first_tail_x15_r0_body.cx1_133 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost133 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0133 PRE_first_tail_x15_r0_body.ckn1133 PRE_first_tail_x15_r0_body.ckheap133 PRE_first_tail_x15_r0_body.ckpl133)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1289.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1289.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1289.ffi) = some PRE_first_tail_x15_r0_body.fxC_133
kernel_rfl PRE_first_tail_x15_r0_body.okrC_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1289.ffi) = some PRE_first_tail_x15_r0_body.krC_133
noncomputable def PRE_first_tail_x15_r0_body.fx0_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1291.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1291.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1291.ffi) = some PRE_first_tail_x15_r0_body.fx0_133
kernel_rfl PRE_first_tail_x15_r0_body.okr0_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1291.ffi) = some PRE_first_tail_x15_r0_body.kr0_133
noncomputable def PRE_first_tail_x15_r0_body.fx1_133 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1290.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_133 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1290.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_133 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1290.ffi) = some PRE_first_tail_x15_r0_body.fx1_133
kernel_rfl PRE_first_tail_x15_r0_body.okr1_133 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1290.ffi) = some PRE_first_tail_x15_r0_body.kr1_133
kernel_rfl PRE_first_tail_x15_r0_body.ff0133 : PRE_first_tail_x15_r0_body.fx0_133 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_133 (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_133.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1133 : PRE_first_tail_x15_r0_body.fx1_133 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_133 (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_133.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck133 : freedLB PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.fx0_133 PRE_first_tail_x15_r0_body.fx1_133 PRE_first_tail_x15_r0_body.clo133 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0133 : PRE_first_tail_x15_r0_body.kr0_133.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.flags (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_133.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0133 : PRE_first_tail_x15_r0_body.kr0_133.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.targs (PRE_first_tail_x15_r0_body.clo133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_133.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1133 : PRE_first_tail_x15_r0_body.kr1_133.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.flags (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_133.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1133 : PRE_first_tail_x15_r0_body.kr1_133.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_133.targs (PRE_first_tail_x15_r0_body.cwS133.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_133.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck133 : krecLB PRE_first_tail_x15_r0_body.kappa133 5765 PRE_first_tail_x15_r0_body.cx0_133.mlx PRE_first_tail_x15_r0_body.kr0_133 PRE_first_tail_x15_r0_body.kr1_133 PRE_first_tail_x15_r0_body.clo133 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn133 : Nat.ble 5765 5765 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge133 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1290.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1291.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR133 : pendRegB PRE_first_tail_x15_r0_body.kappa133 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe133 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1291.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1290.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift133 (clean : Conv.NClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P133.NL) (cl : SSt (· < 5765) PRE_first_tail_x15_r0_body.cx0_133.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_133.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_133.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_133.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1289.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_133.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P133 5765 PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1291.ffi PRE_first_tail_x15_r0_body.s1290.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift133 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue133, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp133 t ht),
    PRE_first_tail_x15_r0_body.cbridge133,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1290.ffi) (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_133 PRE_first_tail_x15_r0_body.ofx1_133 hobjC PRE_first_tail_x15_r0_body.ff0133 PRE_first_tail_x15_r0_body.ff1133 PRE_first_tail_x15_r0_body.ffck133,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1291.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1290.ffi) (PRE_first_tail_x15_r0_body.cfoot133 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_133 PRE_first_tail_x15_r0_body.okr1_133 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn133) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0133 PRE_first_tail_x15_r0_body.fkt0133 PRE_first_tail_x15_r0_body.fkf1133 PRE_first_tail_x15_r0_body.fkt1133 PRE_first_tail_x15_r0_body.fkck133,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0133 PRE_first_tail_x15_r0_body.cnh1133 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe133) PRE_first_tail_x15_r0_body.cpendR133⟩

end Host.Load.Run.Tpl
end

section -- st133/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st133 0
host_stream_state PRE_first_tail_x15_r0_body.st133 1
host_stream_state PRE_first_tail_x15_r0_body.st133 2
end Host.Load.Run.Tpl
end

section -- Site133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 133 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g133__g134` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1289`, the merged state `PRE_first_tail_x15_r0_body.s1290`,
the site template `PRE_first_tail_x15_r0_body.st133` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1291`: the merge.
The footprint's facts are in `SiteF133`, the compaction's in `SiteC133`, `SiteK133`, `SiteNa133`, `SiteNb133`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso133 : PRE_first_tail_x15_r0_body.st133.s0 = { PRE_first_tail_x15_r0_body.s1289 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs133 : List Frame := PRE_first_tail_x15_r0_body.s1289.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_133 : PRE_first_tail_x15_r0_body.S1289.tab.length = 5765
kernel_rfl PRE_first_tail_x15_r0_body.tab0_133 : PRE_first_tail_x15_r0_body.st133.S0.tab = PRE_first_tail_x15_r0_body.S1289.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws133 : List Nat := [3238, 3239]
kernel_rfl PRE_first_tail_x15_r0_body.fresh133 : (PRE_first_tail_x15_r0_body.S1289.tab.all fun e => PRE_first_tail_x15_r0_body.ws133.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1289.oracle.all fun q => PRE_first_tail_x15_r0_body.ws133.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab133 : PRE_first_tail_x15_r0_body.S1290.tab = PRE_first_tail_x15_r0_body.S1289.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws133
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen133 : PRE_first_tail_x15_r0_body.st133.S2.tab.length - PRE_first_tail_x15_r0_body.st133.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged133`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap133 : PRE_first_tail_x15_r0_body.s1290.heap = PRE_first_tail_x15_r0_body.st133.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext133 : PRE_first_tail_x15_r0_body.s1290.next = PRE_first_tail_x15_r0_body.st133.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl133 : PRE_first_tail_x15_r0_body.s1290.ctl = PRE_first_tail_x15_r0_body.st133.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack133 : PRE_first_tail_x15_r0_body.s1290.stack = PRE_first_tail_x15_r0_body.st133.s2.stack ++ PRE_first_tail_x15_r0_body.s1289.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs133 : PRE_first_tail_x15_r0_body.s1290.jobs = PRE_first_tail_x15_r0_body.st133.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi133 : PRE_first_tail_x15_r0_body.s1290.ffi = PRE_first_tail_x15_r0_body.st133.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace133 : PRE_first_tail_x15_r0_body.s1290.trace = PRE_first_tail_x15_r0_body.st133.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores133 : PRE_first_tail_x15_r0_body.s1290.stores = PRE_first_tail_x15_r0_body.st133.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 133 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived133 : PRE_first_tail_x15_r0_body.nr133.map (fun r => nth? PRE_first_tail_x15_r0_body.st133.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo133 : PRE_first_tail_x15_r0_body.nr133.all (Nat.ble 5765) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj133 : PRE_first_tail_x15_r0_body.cws133.all (fun c => !PRE_first_tail_x15_r0_body.ws133.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ133 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws133 PRE_first_tail_x15_r0_body.crs133 PRE_first_tail_x15_r0_body.ws133

end Host.Load.Run.Tpl
end

section -- st133/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st133`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st133.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st133.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st133.s2.heap PRE_first_tail_x15_r0_body.st133.wrR ++ freshOf PRE_first_tail_x15_r0_body.st133.s2.heap PRE_first_tail_x15_r0_body.st133.s0.next PRE_first_tail_x15_r0_body.st133.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st133.wr : List Nat := PRE_first_tail_x15_r0_body.st133.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st133.heapFoot : PRE_first_tail_x15_r0_body.st133.s2.heap = setAll PRE_first_tail_x15_r0_body.st133.s0.heap PRE_first_tail_x15_r0_body.st133.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st133.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st133.s0.next PRE_first_tail_x15_r0_body.st133.s2.next = true
theorem PRE_first_tail_x15_r0_body.st133.grows : PRE_first_tail_x15_r0_body.st133.s0.next ≤ PRE_first_tail_x15_r0_body.st133.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st133.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st133.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st133.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st133.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st133.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st133.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st133.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st133.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st133.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st133.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st133.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st133.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 133 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB133 : nodupT PRE_first_tail_x15_r0_body.st133.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup133 : PRE_first_tail_x15_r0_body.st133.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB133).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB133 : PRE_first_tail_x15_r0_body.st133.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound133 : ∀ b ∈ PRE_first_tail_x15_r0_body.st133.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB133 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr133 := PRE_first_tail_x15_r0_body.st133.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq133 : PRE_first_tail_x15_r0_body.st133.s2.trace = PRE_first_tail_x15_r0_body.trFr133 ++ PRE_first_tail_x15_r0_body.st133.s0.trace
theorem PRE_first_tail_x15_r0_body.trace133 : ∃ fr, PRE_first_tail_x15_r0_body.st133.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st133.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq133⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide133 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB133 : (PRE_first_tail_x15_r0_body.wide133.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st133.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix133 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide133, WFix Map.id (Present PRE_first_tail_x15_r0_body.st133.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB133 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 133 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1290`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO133 : PRE_first_tail_x15_r0_body.st133.S0.oracle = PRE_first_tail_x15_r0_body.st133.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B133 : PRE_first_tail_x15_r0_body.st133.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st133.s0.next || (PRE_first_tail_x15_r0_body.st133.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot133 : Conv.StageFoot PRE_first_tail_x15_r0_body.st133.wr PRE_first_tail_x15_r0_body.st133.s0 PRE_first_tail_x15_r0_body.st133.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st133.heapFoot PRE_first_tail_x15_r0_body.wrNodup133 PRE_first_tail_x15_r0_body.wrBound133 PRE_first_tail_x15_r0_body.wr0B133 PRE_first_tail_x15_r0_body.st133.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged133 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st133.F.S → PRE_first_tail_x15_r0_body.st133.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st133.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st133.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs133 PRE_first_tail_x15_r0_body.st133.wr PRE_first_tail_x15_r0_body.s1289 PRE_first_tail_x15_r0_body.st133.s2 PRE_first_tail_x15_r0_body.st133.s0
      PRE_first_tail_x15_r0_body.st133.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st133.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1290 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso133 PRE_first_tail_x15_r0_body.stFoot133 PRE_first_tail_x15_r0_body.wrNodup133 PRE_first_tail_x15_r0_body.wrBound133 PRE_first_tail_x15_r0_body.trace133 PRE_first_tail_x15_r0_body.mheap133
    PRE_first_tail_x15_r0_body.mnext133 PRE_first_tail_x15_r0_body.mctl133 PRE_first_tail_x15_r0_body.mstack133 PRE_first_tail_x15_r0_body.mjobs133 PRE_first_tail_x15_r0_body.mffi133 PRE_first_tail_x15_r0_body.mtrace133 PRE_first_tail_x15_r0_body.mstores133 h

def PRE_first_tail_x15_r0_body.arrEl133_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE133_2665 : arrOf PRE_first_tail_x15_r0_body.s1290 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl133_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA133_2665 : isArrB PRE_first_tail_x15_r0_body.s1290 2665 = true
theorem PRE_first_tail_x15_r0_body.arr133_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1290.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl133_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE133_2665 PRE_first_tail_x15_r0_body.arrA133_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN133_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl133_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR133_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl133_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN133_2665

def PRE_first_tail_x15_r0_body.arrEl133_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE133_2673467 : arrOf PRE_first_tail_x15_r0_body.s1290 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl133_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA133_2673467 : isArrB PRE_first_tail_x15_r0_body.s1290 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr133_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1290.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl133_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE133_2673467 PRE_first_tail_x15_r0_body.arrA133_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN133_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl133_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR133_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl133_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN133_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k133 : isArrB PRE_first_tail_x15_r0_body.s1290 4910 = false
theorem PRE_first_tail_x15_r0_body.keep133 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1290 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k133 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr133_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl133_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ133
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 133 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1289`, the merged
state `PRE_first_tail_x15_r0_body.s1290`, the canonical state `PRE_first_tail_x15_r0_body.s1291`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl133 : PRE_first_tail_x15_r0_body.pl133.all (Nat.ble PRE_first_tail_x15_r0_body.s1289.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd133 : nodupT PRE_first_tail_x15_r0_body.pl133 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1133 : Nat.ble PRE_first_tail_x15_r0_body.s1289.next 2779533 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst133 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1289.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn133 : PRE_first_tail_x15_r0_body.s1291.next = PRE_first_tail_x15_r0_body.s1289.next + PRE_first_tail_x15_r0_body.pl133.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn133 : PRE_first_tail_x15_r0_body.s1290.next = 2779533
kernel_rfl PRE_first_tail_x15_r0_body.zgrow133 : Nat.ble PRE_first_tail_x15_r0_body.s1291.next PRE_first_tail_x15_r0_body.s1290.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh133 : PRE_first_tail_x15_r0_body.S1289.tab.all (fun e => PRE_first_tail_x15_r0_body.cws133.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd133 : nodupT PRE_first_tail_x15_r0_body.cws133 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi133 : PRE_first_tail_x15_r0_body.nr133.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1290.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt133 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1289.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg133_2665 : PRE_first_tail_x15_r0_body.s1291.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1291 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk133_2665 : (objOf PRE_first_tail_x15_r0_body.s1291 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm133_2665 : PRE_first_tail_x15_r0_body.s1290.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa133.obj (objOf PRE_first_tail_x15_r0_body.s1291 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1290 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg133_2673467 : PRE_first_tail_x15_r0_body.s1291.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1291 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk133_2673467 : (objOf PRE_first_tail_x15_r0_body.s1291 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm133_2673467 : PRE_first_tail_x15_r0_body.s1290.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa133.obj (objOf PRE_first_tail_x15_r0_body.s1291 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1290 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw133_4910 : (PRE_first_tail_x15_r0_body.s1291.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw133_2673472 : (PRE_first_tail_x15_r0_body.s1291.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw133_2673473 : (PRE_first_tail_x15_r0_body.s1291.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd133 : PRE_first_tail_x15_r0_body.cl133.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr133 : PRE_first_tail_x15_r0_body.st133.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1289.next || PRE_first_tail_x15_r0_body.cl133.contains b) = true
def PRE_first_tail_x15_r0_body.zl133 : List Nat := PRE_first_tail_x15_r0_body.cl133.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE133 : PRE_first_tail_x15_r0_body.zl133.map (fun a => PRE_first_tail_x15_r0_body.s1290.heap.get (PRE_first_tail_x15_r0_body.kappa133.a a)) = PRE_first_tail_x15_r0_body.zl133.map (fun a => (PRE_first_tail_x15_r0_body.s1291.heap.get a).map PRE_first_tail_x15_r0_body.kappa133.hobj)
theorem PRE_first_tail_x15_r0_body.zimg133 : HeapImg PRE_first_tail_x15_r0_body.kappa133 PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.s1290 PRE_first_tail_x15_r0_body.zl133 := PRE_first_tail_x15_r0_body.zimgE133
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl133 : PRE_first_tail_x15_r0_body.s1290.ctl = PRE_first_tail_x15_r0_body.kappa133.ctl PRE_first_tail_x15_r0_body.s1291.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack133 : PRE_first_tail_x15_r0_body.s1290.stack = PRE_first_tail_x15_r0_body.s1291.stack.map PRE_first_tail_x15_r0_body.kappa133.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs133 : PRE_first_tail_x15_r0_body.s1290.jobs = PRE_first_tail_x15_r0_body.s1291.jobs.map PRE_first_tail_x15_r0_body.kappa133.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores133 : PRE_first_tail_x15_r0_body.s1290.stores = PRE_first_tail_x15_r0_body.kappa133.stores PRE_first_tail_x15_r0_body.s1291.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots133 : checkRootsSupp PRE_first_tail_x15_r0_body.s1291 5765 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC133 : PRE_first_tail_x15_r0_body.S1289.tab.length + PRE_first_tail_x15_r0_body.cws133.length = 5765
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap133 : PRE_first_tail_x15_r0_body.kappa133 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1289.next 2779533 PRE_first_tail_x15_r0_body.S1289.tab.length PRE_first_tail_x15_r0_body.pl133 (PRE_first_tail_x15_r0_body.nr133.map NumV.ref) PRE_first_tail_x15_r0_body.kd133.big
  PRE_first_tail_x15_r0_body.kd133.region PRE_first_tail_x15_r0_body.kd133.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin133 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1291.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc133 : Conv.jcleanListB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1291 PRE_first_tail_x15_r0_body.cl133 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB133 : noBigRootsP (fun i => !Conv.oldBigB (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1291.trace PRE_first_tail_x15_r0_body.s1291 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm133 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17925 = true
theorem PRE_first_tail_x15_r0_body.cjcl133 (h : Conv.JClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1289) : Conv.JClean (⟨20828, 17925, 2779531, 5765⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1291 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle133)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap133 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd133 a ha)) PRE_first_tail_x15_r0_body.zjc133

end Host.Load.Run.Tpl
end

section -- st133/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st133.bodyLast from PRE_first_tail_x15_r0_body.st133.s1 to PRE_first_tail_x15_r0_body.st133.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st133.F PRE_first_tail_x15_r0_body.st133.s1).run PRE_first_tail_x15_r0_body.st133.S1 = some (PRE_first_tail_x15_r0_body.st133.s2, PRE_first_tail_x15_r0_body.st133.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st133.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st133.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st133.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st133.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st133/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st133.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st133.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st133.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st133.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st133.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st133.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st133.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st133.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st133.s0 PRE_first_tail_x15_r0_body.st133.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st133.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st133.s1 PRE_first_tail_x15_r0_body.st133.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st133/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st133.bodyK0F from PRE_first_tail_x15_r0_body.st133.s0 to PRE_first_tail_x15_r0_body.st133.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st133.F (PRE_first_tail_x15_r0_body.st133.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st133.ks 0).getD 0) PRE_first_tail_x15_r0_body.st133.s0 PRE_first_tail_x15_r0_body.st133.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st133.s1, PRE_first_tail_x15_r0_body.st133.S1)
theorem PRE_first_tail_x15_r0_body.st133.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st133.F (PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st133.ks 0).getD 0) PRE_first_tail_x15_r0_body.st133.s0 PRE_first_tail_x15_r0_body.st133.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st133.s1, PRE_first_tail_x15_r0_body.st133.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st133.bodyOkLN_ok PRE_first_tail_x15_r0_body.st133.bodyK0F
end Host.Load.Run.Tpl
end

section -- st133/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st133.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st133.F (PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st133.s0 PRE_first_tail_x15_r0_body.st133.S0 = some (PRE_first_tail_x15_r0_body.st133.s1, PRE_first_tail_x15_r0_body.st133.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st133.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st133.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st133.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st133.F (PRE_first_tail_x15_r0_body.st133.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st133.s0
  S0 := PRE_first_tail_x15_r0_body.st133.S0
  s1 := PRE_first_tail_x15_r0_body.st133.s1
  S1 := PRE_first_tail_x15_r0_body.st133.S1
  s2 := PRE_first_tail_x15_r0_body.st133.s2
  S2 := PRE_first_tail_x15_r0_body.st133.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st133.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st133.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st133.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st133.bodyHalt
  last := PRE_first_tail_x15_r0_body.st133.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st133.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 134 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1295` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa134` into the merged state
`PRE_first_tail_x15_r0_body.s1294`. -/

def PRE_first_tail_x15_r0_body.pl134 : List Nat := [2779829]
def PRE_first_tail_x15_r0_body.nr134 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd134 : RData :=
  ⟨2779820, 2779830, Stage.setAll PTrie.nil [(2779819, 2779829)], Stage.setAll PTrie.nil [],
   20835, 20835, 17929, 17929, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa134 : Map :=
  Conv.Map.compact 2779819 2779830 5782 PRE_first_tail_x15_r0_body.pl134 (PRE_first_tail_x15_r0_body.nr134.map NumV.ref) PRE_first_tail_x15_r0_body.kd134.big
    PRE_first_tail_x15_r0_body.kd134.region PRE_first_tail_x15_r0_body.kd134.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws134 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs134 : List SymE := PRE_first_tail_x15_r0_body.nr134.map fun r => (nth? PRE_first_tail_x15_r0_body.S1294.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta134 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws134 PRE_first_tail_x15_r0_body.crs134
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB134 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab134 : PRE_first_tail_x15_r0_body.S1295.tab = PRE_first_tail_x15_r0_body.S1293.tab ++ PRE_first_tail_x15_r0_body.cws134.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace134 : PRE_first_tail_x15_r0_body.s1295.trace = PRE_first_tail_x15_r0_body.s1293.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext134 : PRE_first_tail_x15_r0_body.s1295.next = 2779820
kernel_rfl PRE_first_tail_x15_r0_body.ccounters134 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.nnext) = (20835, 17929)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa134.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.tokens.all (bSN 5782) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean134 : Conv.cleanListB 20835 131072 (fun r => Nat.ble 83340 r) PRE_first_tail_x15_r0_body.s1295
    (PRE_first_tail_x15_r0_body.wrB134 ++ (List.range 1).map (2779819 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs134 : bigsOutB 20835 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl134`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl134 : List Nat := [2665, 2673467, 2779819]
def PRE_first_tail_x15_r0_body.clo134 : List Nat := []
def PRE_first_tail_x15_r0_body.cln134 : List Nat := []
def PRE_first_tail_x15_r0_body.cli134 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap134 : PRE_first_tail_x15_r0_body.s1295.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1293.heap (PRE_first_tail_x15_r0_body.cl134.filterMap fun a => (PRE_first_tail_x15_r0_body.s1295.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe134 : Nat.ble PRE_first_tail_x15_r0_body.s1293.next PRE_first_tail_x15_r0_body.s1295.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP134 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.cl134 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp134 : Conv.suppListB PRE_first_tail_x15_r0_body.s1295 5782 PRE_first_tail_x15_r0_body.cl134 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound134 : Conv.boundListB PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.cl134 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln134.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli134.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst134 : Conv.sstListB 5782 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx PRE_first_tail_x15_r0_body.cln134 PRE_first_tail_x15_r0_body.clo134 PRE_first_tail_x15_r0_body.cli134 = true

end Host.Load.Run.Tpl
end

section -- SiteCl134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA134 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd134 : (PRE_first_tail_x15_r0_body.clo134 ++ PRE_first_tail_x15_r0_body.cln134 ++ PRE_first_tail_x15_r0_body.cli134).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle134 : Conv.Cnt.leB (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck134 : Conv.ncleanListB (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx PRE_first_tail_x15_r0_body.clo134 PRE_first_tail_x15_r0_body.cln134 PRE_first_tail_x15_r0_body.cli134 = true
theorem PRE_first_tail_x15_r0_body.cncl134 (h : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) : Conv.NClean (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle134 PRE_first_tail_x15_r0_body.ckA134 PRE_first_tail_x15_r0_body.cobjsK134 PRE_first_tail_x15_r0_body.cnodesK134 PRE_first_tail_x15_r0_body.citemsK134 PRE_first_tail_x15_r0_body.cbd134 PRE_first_tail_x15_r0_body.cck134

end Host.Load.Run.Tpl
end

section -- SiteS134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 134 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc134 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P134 : LoadP := PRE_first_tail_x15_r0_body.Pc134.raise 17929
kernel_rfl PRE_first_tail_x15_r0_body.craise134 : Nat.ble PRE_first_tail_x15_r0_body.Pc134.N0 17929 = true
theorem PRE_first_tail_x15_r0_body.raised134 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc134 PRE_first_tail_x15_r0_body.P134 :=
  .inr ⟨17929, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise134, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_134 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_134 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi)
def PRE_first_tail_x15_r0_body.khinv134 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv134 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS134 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS134 : List Nat := List.range' 17929 0
def PRE_first_tail_x15_r0_body.ciS134 : List Nat := [] ++ List.range' 17929 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0134 : PRE_first_tail_x15_r0_body.kd134.nh0 = PRE_first_tail_x15_r0_body.cx0_134.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1134 : PRE_first_tail_x15_r0_body.kd134.nh1 = PRE_first_tail_x15_r0_body.cx1_134.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0134 : PRE_first_tail_x15_r0_body.kd134.nn0 = PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1134 : PRE_first_tail_x15_r0_body.kd134.nn1 = PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo134 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P134.lo && Nat.ble PRE_first_tail_x15_r0_body.P134.lo PRE_first_tail_x15_r0_body.cx0_134.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P134.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P134.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt134 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_134.mlx.next PRE_first_tail_x15_r0_body.cx1_134.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband134 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P134.NL && Nat.ble PRE_first_tail_x15_r0_body.P134.NL PRE_first_tail_x15_r0_body.P134.N0 && Nat.ble PRE_first_tail_x15_r0_body.P134.N0 PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow134 : PRE_first_tail_x15_r0_body.kd134.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren134 : checkRenG PRE_first_tail_x15_r0_body.kd134.hnd PRE_first_tail_x15_r0_body.khinv134 (phB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband134 : PRE_first_tail_x15_r0_body.kd134.checkBand PRE_first_tail_x15_r0_body.P134.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos134 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd134.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren134 : checkRenG PRE_first_tail_x15_r0_body.kd134.node PRE_first_tail_x15_r0_body.kninv134 (pnB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P134.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd134.nodeF j) PRE_first_tail_x15_r0_body.cx1_134.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a134 : PRE_first_tail_x15_r0_body.cx0_134.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b134 : PRE_first_tail_x15_r0_body.cx0_134.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.pending = PRE_first_tail_x15_r0_body.cx0_134.mlx.pending.map PRE_first_tail_x15_r0_body.kappa134.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.errh = PRE_first_tail_x15_r0_body.cx0_134.mlx.errh.map PRE_first_tail_x15_r0_body.kappa134.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.files = PRE_first_tail_x15_r0_body.cx0_134.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.arch = PRE_first_tail_x15_r0_body.cx0_134.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_134.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.wired = PRE_first_tail_x15_r0_body.cx0_134.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost134 : PRE_first_tail_x15_r0_body.cx1_134.host = PRE_first_tail_x15_r0_body.cx0_134.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd134`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0134 : PRE_first_tail_x15_r0_body.kd134.n0 = 2779820
kernel_rfl PRE_first_tail_x15_r0_body.ckn1134 : PRE_first_tail_x15_r0_body.kd134.n1 = 2779830
kernel_rfl PRE_first_tail_x15_r0_body.ckheap134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.heap).all (fun x => Nat.ble 2779819 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl134 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd134.heap.get (2779819 + j) = nth? PRE_first_tail_x15_r0_body.pl134 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja134 : Nat.ble 2779819 2779819 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn134 : Nat.ble 5782 5782 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD134 : Nat.ble 2779819 PRE_first_tail_x15_r0_body.kd134.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn134 : Nat.ble 20835 PRE_first_tail_x15_r0_body.kd134.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn134 : Nat.ble 17929 PRE_first_tail_x15_r0_body.kd134.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb134 : Nat.ble 20835 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.heap).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.hnd).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (Nat.ble (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix134 : Conv.FixOld (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa134 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn134) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb134) PRE_first_tail_x15_r0_body.fheap134 PRE_first_tail_x15_r0_body.fhnd134 PRE_first_tail_x15_r0_body.fnode134
kernel_rfl PRE_first_tail_x15_r0_body.fcxn134 : (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn134 : (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0134 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_134.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_134.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I134 : PRE_first_tail_x15_r0_body.cx1_134.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS134.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd134 : (PRE_first_tail_x15_r0_body.clo134 ++ PRE_first_tail_x15_r0_body.cln134 ++ PRE_first_tail_x15_r0_body.cli134 ++ PRE_first_tail_x15_r0_body.cwS134 ++ PRE_first_tail_x15_r0_body.cnS134 ++ PRE_first_tail_x15_r0_body.ciS134).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW134 : PRE_first_tail_x15_r0_body.cwS134.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo134.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI134 : PRE_first_tail_x15_r0_body.ciS134.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli134.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN134 : PRE_first_tail_x15_r0_body.cnS134.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF134 : PRE_first_tail_x15_r0_body.cln134.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh134 : PRE_first_tail_x15_r0_body.clo134.all (handleOK PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134.lo PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo134 : PRE_first_tail_x15_r0_body.clo134.map (fun h => PRE_first_tail_x15_r0_body.cx1_134.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa134.handle h)) = PRE_first_tail_x15_r0_body.clo134.map (fun h => (PRE_first_tail_x15_r0_body.cx0_134.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa134.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok134 : PRE_first_tail_x15_r0_body.clo134.all (objOK PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134.NL PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd134 : PRE_first_tail_x15_r0_body.cln134.all (nodeOKF PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.P134 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp134 : ((PRE_first_tail_x15_r0_body.cln134.filter (fullB PRE_first_tail_x15_r0_body.P134))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_134.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa134.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln134.filter (fullB PRE_first_tail_x15_r0_body.P134))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_134.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa134.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI134 : incrB PRE_first_tail_x15_r0_body.kd134.nodeF (List.range' 17929 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK134 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all (fun k => Nat.ble 17929 k && Nat.blt k 17929) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL134 : (PRE_first_tail_x15_r0_body.cln134.filter (Nat.ble PRE_first_tail_x15_r0_body.P134.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd134.nodeF i) && (Nat.blt i 17929 || Nat.ble PRE_first_tail_x15_r0_body.kd134.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord134 : (PRE_first_tail_x15_r0_body.cln134.filter (Nat.ble PRE_first_tail_x15_r0_body.P134.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd134.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd134.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd134.nodeF j) (PRE_first_tail_x15_r0_body.kd134.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow134 PRE_first_tail_x15_r0_body.cnn1134 PRE_first_tail_x15_r0_body.fnordI134 PRE_first_tail_x15_r0_body.fnordK134 PRE_first_tail_x15_r0_body.fnordL134
kernel_rfl PRE_first_tail_x15_r0_body.fi134 : PRE_first_tail_x15_r0_body.cli134.all (pnB PRE_first_tail_x15_r0_body.cx0_134.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii134 : PRE_first_tail_x15_r0_body.cli134.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_134.mlx.items.get (PRE_first_tail_x15_r0_body.kappa134.node k) = (PRE_first_tail_x15_r0_body.cx0_134.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa134.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.kd134 PRE_first_tail_x15_r0_body.khinv134 PRE_first_tail_x15_r0_body.kninv134 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.cx1_134.mlx (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo134 PRE_first_tail_x15_r0_body.cln134 PRE_first_tail_x15_r0_body.cli134 PRE_first_tail_x15_r0_body.cwS134 PRE_first_tail_x15_r0_body.cnS134 PRE_first_tail_x15_r0_body.ciS134 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0134, PRE_first_tail_x15_r0_body.cnh1134, PRE_first_tail_x15_r0_body.cnn0134, PRE_first_tail_x15_r0_body.cnn1134, PRE_first_tail_x15_r0_body.cplo134, PRE_first_tail_x15_r0_body.ccnt134, PRE_first_tail_x15_r0_body.cnband134, PRE_first_tail_x15_r0_body.chbelow134, PRE_first_tail_x15_r0_body.chren134, PRE_first_tail_x15_r0_body.cband134, PRE_first_tail_x15_r0_body.cnh1pos134, PRE_first_tail_x15_r0_body.cnren134, PRE_first_tail_x15_r0_body.cnlow134, PRE_first_tail_x15_r0_body.cabs0a134, PRE_first_tail_x15_r0_body.cabs0b134, PRE_first_tail_x15_r0_body.ctok1134, PRE_first_tail_x15_r0_body.cpend134, PRE_first_tail_x15_r0_body.cerrh134, PRE_first_tail_x15_r0_body.cfiles134, PRE_first_tail_x15_r0_body.carch134, PRE_first_tail_x15_r0_body.csizes134, PRE_first_tail_x15_r0_body.cwired134, PRE_first_tail_x15_r0_body.cfix134, clean, PRE_first_tail_x15_r0_body.fcxn134, PRE_first_tail_x15_r0_body.fcnn134, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0134, PRE_first_tail_x15_r0_body.fnk134, PRE_first_tail_x15_r0_body.ckA134, PRE_first_tail_x15_r0_body.cobjsK134, PRE_first_tail_x15_r0_body.cnodesK134, PRE_first_tail_x15_r0_body.citemsK134, PRE_first_tail_x15_r0_body.f1A134, PRE_first_tail_x15_r0_body.f1O134, PRE_first_tail_x15_r0_body.f1N134, PRE_first_tail_x15_r0_body.f1I134, PRE_first_tail_x15_r0_body.fbd134, PRE_first_tail_x15_r0_body.fincW134, PRE_first_tail_x15_r0_body.fincI134, PRE_first_tail_x15_r0_body.fincN134, PRE_first_tail_x15_r0_body.flnF134, PRE_first_tail_x15_r0_body.fh134, PRE_first_tail_x15_r0_body.fo134, PRE_first_tail_x15_r0_body.fok134, PRE_first_tail_x15_r0_body.fnd134, PRE_first_tail_x15_r0_body.fp134, PRE_first_tail_x15_r0_body.fnord134, PRE_first_tail_x15_r0_body.fi134, PRE_first_tail_x15_r0_body.fii134⟩
theorem PRE_first_tail_x15_r0_body.cnshift134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx) : NShift PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.cx0_134 PRE_first_tail_x15_r0_body.cx1_134 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost134 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0134 PRE_first_tail_x15_r0_body.ckn1134 PRE_first_tail_x15_r0_body.ckheap134 PRE_first_tail_x15_r0_body.ckpl134)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1293.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1293.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1293.ffi) = some PRE_first_tail_x15_r0_body.fxC_134
kernel_rfl PRE_first_tail_x15_r0_body.okrC_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1293.ffi) = some PRE_first_tail_x15_r0_body.krC_134
noncomputable def PRE_first_tail_x15_r0_body.fx0_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1295.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1295.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1295.ffi) = some PRE_first_tail_x15_r0_body.fx0_134
kernel_rfl PRE_first_tail_x15_r0_body.okr0_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1295.ffi) = some PRE_first_tail_x15_r0_body.kr0_134
noncomputable def PRE_first_tail_x15_r0_body.fx1_134 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1294.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_134 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1294.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_134 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1294.ffi) = some PRE_first_tail_x15_r0_body.fx1_134
kernel_rfl PRE_first_tail_x15_r0_body.okr1_134 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1294.ffi) = some PRE_first_tail_x15_r0_body.kr1_134
kernel_rfl PRE_first_tail_x15_r0_body.ff0134 : PRE_first_tail_x15_r0_body.fx0_134 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_134 (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_134.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1134 : PRE_first_tail_x15_r0_body.fx1_134 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_134 (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_134.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck134 : freedLB PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.fx0_134 PRE_first_tail_x15_r0_body.fx1_134 PRE_first_tail_x15_r0_body.clo134 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0134 : PRE_first_tail_x15_r0_body.kr0_134.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.flags (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_134.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0134 : PRE_first_tail_x15_r0_body.kr0_134.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.targs (PRE_first_tail_x15_r0_body.clo134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_134.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1134 : PRE_first_tail_x15_r0_body.kr1_134.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.flags (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_134.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1134 : PRE_first_tail_x15_r0_body.kr1_134.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_134.targs (PRE_first_tail_x15_r0_body.cwS134.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_134.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck134 : krecLB PRE_first_tail_x15_r0_body.kappa134 5782 PRE_first_tail_x15_r0_body.cx0_134.mlx PRE_first_tail_x15_r0_body.kr0_134 PRE_first_tail_x15_r0_body.kr1_134 PRE_first_tail_x15_r0_body.clo134 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn134 : Nat.ble 5782 5782 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge134 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1294.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1295.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR134 : pendRegB PRE_first_tail_x15_r0_body.kappa134 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe134 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1295.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1294.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift134 (clean : Conv.NClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P134.NL) (cl : SSt (· < 5782) PRE_first_tail_x15_r0_body.cx0_134.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_134.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_134.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_134.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1293.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_134.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P134 5782 PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295.ffi PRE_first_tail_x15_r0_body.s1294.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift134 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue134, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp134 t ht),
    PRE_first_tail_x15_r0_body.cbridge134,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1295.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1294.ffi) (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_134 PRE_first_tail_x15_r0_body.ofx1_134 hobjC PRE_first_tail_x15_r0_body.ff0134 PRE_first_tail_x15_r0_body.ff1134 PRE_first_tail_x15_r0_body.ffck134,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1295.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1294.ffi) (PRE_first_tail_x15_r0_body.cfoot134 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_134 PRE_first_tail_x15_r0_body.okr1_134 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn134) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0134 PRE_first_tail_x15_r0_body.fkt0134 PRE_first_tail_x15_r0_body.fkf1134 PRE_first_tail_x15_r0_body.fkt1134 PRE_first_tail_x15_r0_body.fkck134,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0134 PRE_first_tail_x15_r0_body.cnh1134 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe134) PRE_first_tail_x15_r0_body.cpendR134⟩

end Host.Load.Run.Tpl
end

section -- st134/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st134 0
host_stream_state PRE_first_tail_x15_r0_body.st134 1
host_stream_state PRE_first_tail_x15_r0_body.st134 2
end Host.Load.Run.Tpl
end

section -- Site134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 134 of chain `PRE_first_tail_x15_r0_body`: `plan__g134__g135` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1293`, the merged state `PRE_first_tail_x15_r0_body.s1294`,
the site template `PRE_first_tail_x15_r0_body.st134` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1295`: the merge.
The footprint's facts are in `SiteF134`, the compaction's in `SiteC134`, `SiteK134`, `SiteNa134`, `SiteNb134`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso134 : PRE_first_tail_x15_r0_body.st134.s0 = { PRE_first_tail_x15_r0_body.s1293 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs134 : List Frame := PRE_first_tail_x15_r0_body.s1293.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_134 : PRE_first_tail_x15_r0_body.S1293.tab.length = 5782
kernel_rfl PRE_first_tail_x15_r0_body.tab0_134 : PRE_first_tail_x15_r0_body.st134.S0.tab = PRE_first_tail_x15_r0_body.S1293.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws134 : List Nat := [3240, 3241, 3242]
kernel_rfl PRE_first_tail_x15_r0_body.fresh134 : (PRE_first_tail_x15_r0_body.S1293.tab.all fun e => PRE_first_tail_x15_r0_body.ws134.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1293.oracle.all fun q => PRE_first_tail_x15_r0_body.ws134.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab134 : PRE_first_tail_x15_r0_body.S1294.tab = PRE_first_tail_x15_r0_body.S1293.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws134
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen134 : PRE_first_tail_x15_r0_body.st134.S2.tab.length - PRE_first_tail_x15_r0_body.st134.S0.tab.length = 3

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged134`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap134 : PRE_first_tail_x15_r0_body.s1294.heap = PRE_first_tail_x15_r0_body.st134.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext134 : PRE_first_tail_x15_r0_body.s1294.next = PRE_first_tail_x15_r0_body.st134.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl134 : PRE_first_tail_x15_r0_body.s1294.ctl = PRE_first_tail_x15_r0_body.st134.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack134 : PRE_first_tail_x15_r0_body.s1294.stack = PRE_first_tail_x15_r0_body.st134.s2.stack ++ PRE_first_tail_x15_r0_body.s1293.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs134 : PRE_first_tail_x15_r0_body.s1294.jobs = PRE_first_tail_x15_r0_body.st134.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi134 : PRE_first_tail_x15_r0_body.s1294.ffi = PRE_first_tail_x15_r0_body.st134.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace134 : PRE_first_tail_x15_r0_body.s1294.trace = PRE_first_tail_x15_r0_body.st134.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores134 : PRE_first_tail_x15_r0_body.s1294.stores = PRE_first_tail_x15_r0_body.st134.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 134 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived134 : PRE_first_tail_x15_r0_body.nr134.map (fun r => nth? PRE_first_tail_x15_r0_body.st134.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo134 : PRE_first_tail_x15_r0_body.nr134.all (Nat.ble 5782) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj134 : PRE_first_tail_x15_r0_body.cws134.all (fun c => !PRE_first_tail_x15_r0_body.ws134.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ134 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws134 PRE_first_tail_x15_r0_body.crs134 PRE_first_tail_x15_r0_body.ws134

end Host.Load.Run.Tpl
end

section -- st134/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st134`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st134.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st134.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st134.s2.heap PRE_first_tail_x15_r0_body.st134.wrR ++ freshOf PRE_first_tail_x15_r0_body.st134.s2.heap PRE_first_tail_x15_r0_body.st134.s0.next PRE_first_tail_x15_r0_body.st134.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st134.wr : List Nat := PRE_first_tail_x15_r0_body.st134.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st134.heapFoot : PRE_first_tail_x15_r0_body.st134.s2.heap = setAll PRE_first_tail_x15_r0_body.st134.s0.heap PRE_first_tail_x15_r0_body.st134.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st134.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st134.s0.next PRE_first_tail_x15_r0_body.st134.s2.next = true
theorem PRE_first_tail_x15_r0_body.st134.grows : PRE_first_tail_x15_r0_body.st134.s0.next ≤ PRE_first_tail_x15_r0_body.st134.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st134.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st134.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st134.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st134.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st134.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st134.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st134.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st134.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st134.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st134.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st134.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st134.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 134 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB134 : nodupT PRE_first_tail_x15_r0_body.st134.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup134 : PRE_first_tail_x15_r0_body.st134.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB134).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB134 : PRE_first_tail_x15_r0_body.st134.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound134 : ∀ b ∈ PRE_first_tail_x15_r0_body.st134.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB134 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr134 := PRE_first_tail_x15_r0_body.st134.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq134 : PRE_first_tail_x15_r0_body.st134.s2.trace = PRE_first_tail_x15_r0_body.trFr134 ++ PRE_first_tail_x15_r0_body.st134.s0.trace
theorem PRE_first_tail_x15_r0_body.trace134 : ∃ fr, PRE_first_tail_x15_r0_body.st134.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st134.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq134⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide134 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB134 : (PRE_first_tail_x15_r0_body.wide134.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st134.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix134 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide134, WFix Map.id (Present PRE_first_tail_x15_r0_body.st134.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB134 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 134 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1294`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO134 : PRE_first_tail_x15_r0_body.st134.S0.oracle = PRE_first_tail_x15_r0_body.st134.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B134 : PRE_first_tail_x15_r0_body.st134.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st134.s0.next || (PRE_first_tail_x15_r0_body.st134.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot134 : Conv.StageFoot PRE_first_tail_x15_r0_body.st134.wr PRE_first_tail_x15_r0_body.st134.s0 PRE_first_tail_x15_r0_body.st134.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st134.heapFoot PRE_first_tail_x15_r0_body.wrNodup134 PRE_first_tail_x15_r0_body.wrBound134 PRE_first_tail_x15_r0_body.wr0B134 PRE_first_tail_x15_r0_body.st134.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged134 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st134.F.S → PRE_first_tail_x15_r0_body.st134.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st134.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st134.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs134 PRE_first_tail_x15_r0_body.st134.wr PRE_first_tail_x15_r0_body.s1293 PRE_first_tail_x15_r0_body.st134.s2 PRE_first_tail_x15_r0_body.st134.s0
      PRE_first_tail_x15_r0_body.st134.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st134.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1294 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso134 PRE_first_tail_x15_r0_body.stFoot134 PRE_first_tail_x15_r0_body.wrNodup134 PRE_first_tail_x15_r0_body.wrBound134 PRE_first_tail_x15_r0_body.trace134 PRE_first_tail_x15_r0_body.mheap134
    PRE_first_tail_x15_r0_body.mnext134 PRE_first_tail_x15_r0_body.mctl134 PRE_first_tail_x15_r0_body.mstack134 PRE_first_tail_x15_r0_body.mjobs134 PRE_first_tail_x15_r0_body.mffi134 PRE_first_tail_x15_r0_body.mtrace134 PRE_first_tail_x15_r0_body.mstores134 h

def PRE_first_tail_x15_r0_body.arrEl134_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE134_2665 : arrOf PRE_first_tail_x15_r0_body.s1294 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl134_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA134_2665 : isArrB PRE_first_tail_x15_r0_body.s1294 2665 = true
theorem PRE_first_tail_x15_r0_body.arr134_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1294.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl134_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE134_2665 PRE_first_tail_x15_r0_body.arrA134_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN134_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl134_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR134_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl134_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN134_2665

def PRE_first_tail_x15_r0_body.arrEl134_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE134_2673467 : arrOf PRE_first_tail_x15_r0_body.s1294 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl134_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA134_2673467 : isArrB PRE_first_tail_x15_r0_body.s1294 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr134_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1294.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl134_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE134_2673467 PRE_first_tail_x15_r0_body.arrA134_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN134_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl134_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR134_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl134_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN134_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k134 : isArrB PRE_first_tail_x15_r0_body.s1294 4910 = false
theorem PRE_first_tail_x15_r0_body.keep134 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1294 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k134 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr134_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl134_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ134
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 134 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1293`, the merged
state `PRE_first_tail_x15_r0_body.s1294`, the canonical state `PRE_first_tail_x15_r0_body.s1295`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl134 : PRE_first_tail_x15_r0_body.pl134.all (Nat.ble PRE_first_tail_x15_r0_body.s1293.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd134 : nodupT PRE_first_tail_x15_r0_body.pl134 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1134 : Nat.ble PRE_first_tail_x15_r0_body.s1293.next 2779830 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst134 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1293.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn134 : PRE_first_tail_x15_r0_body.s1295.next = PRE_first_tail_x15_r0_body.s1293.next + PRE_first_tail_x15_r0_body.pl134.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn134 : PRE_first_tail_x15_r0_body.s1294.next = 2779830
kernel_rfl PRE_first_tail_x15_r0_body.zgrow134 : Nat.ble PRE_first_tail_x15_r0_body.s1295.next PRE_first_tail_x15_r0_body.s1294.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh134 : PRE_first_tail_x15_r0_body.S1293.tab.all (fun e => PRE_first_tail_x15_r0_body.cws134.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd134 : nodupT PRE_first_tail_x15_r0_body.cws134 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi134 : PRE_first_tail_x15_r0_body.nr134.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1294.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt134 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1293.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg134_2665 : PRE_first_tail_x15_r0_body.s1295.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1295 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk134_2665 : (objOf PRE_first_tail_x15_r0_body.s1295 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm134_2665 : PRE_first_tail_x15_r0_body.s1294.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa134.obj (objOf PRE_first_tail_x15_r0_body.s1295 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1294 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg134_2673467 : PRE_first_tail_x15_r0_body.s1295.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1295 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk134_2673467 : (objOf PRE_first_tail_x15_r0_body.s1295 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm134_2673467 : PRE_first_tail_x15_r0_body.s1294.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa134.obj (objOf PRE_first_tail_x15_r0_body.s1295 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1294 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw134_4910 : (PRE_first_tail_x15_r0_body.s1295.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw134_2673472 : (PRE_first_tail_x15_r0_body.s1295.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw134_2673473 : (PRE_first_tail_x15_r0_body.s1295.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd134 : PRE_first_tail_x15_r0_body.cl134.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr134 : PRE_first_tail_x15_r0_body.st134.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1293.next || PRE_first_tail_x15_r0_body.cl134.contains b) = true
def PRE_first_tail_x15_r0_body.zl134 : List Nat := PRE_first_tail_x15_r0_body.cl134.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE134 : PRE_first_tail_x15_r0_body.zl134.map (fun a => PRE_first_tail_x15_r0_body.s1294.heap.get (PRE_first_tail_x15_r0_body.kappa134.a a)) = PRE_first_tail_x15_r0_body.zl134.map (fun a => (PRE_first_tail_x15_r0_body.s1295.heap.get a).map PRE_first_tail_x15_r0_body.kappa134.hobj)
theorem PRE_first_tail_x15_r0_body.zimg134 : HeapImg PRE_first_tail_x15_r0_body.kappa134 PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.s1294 PRE_first_tail_x15_r0_body.zl134 := PRE_first_tail_x15_r0_body.zimgE134
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl134 : PRE_first_tail_x15_r0_body.s1294.ctl = PRE_first_tail_x15_r0_body.kappa134.ctl PRE_first_tail_x15_r0_body.s1295.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack134 : PRE_first_tail_x15_r0_body.s1294.stack = PRE_first_tail_x15_r0_body.s1295.stack.map PRE_first_tail_x15_r0_body.kappa134.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs134 : PRE_first_tail_x15_r0_body.s1294.jobs = PRE_first_tail_x15_r0_body.s1295.jobs.map PRE_first_tail_x15_r0_body.kappa134.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores134 : PRE_first_tail_x15_r0_body.s1294.stores = PRE_first_tail_x15_r0_body.kappa134.stores PRE_first_tail_x15_r0_body.s1295.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots134 : checkRootsSupp PRE_first_tail_x15_r0_body.s1295 5782 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC134 : PRE_first_tail_x15_r0_body.S1293.tab.length + PRE_first_tail_x15_r0_body.cws134.length = 5782
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap134 : PRE_first_tail_x15_r0_body.kappa134 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1293.next 2779830 PRE_first_tail_x15_r0_body.S1293.tab.length PRE_first_tail_x15_r0_body.pl134 (PRE_first_tail_x15_r0_body.nr134.map NumV.ref) PRE_first_tail_x15_r0_body.kd134.big
  PRE_first_tail_x15_r0_body.kd134.region PRE_first_tail_x15_r0_body.kd134.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin134 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1295.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc134 : Conv.jcleanListB (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.cl134 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB134 : noBigRootsP (fun i => !Conv.oldBigB (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1295.trace PRE_first_tail_x15_r0_body.s1295 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm134 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17929 = true
theorem PRE_first_tail_x15_r0_body.cjcl134 (h : Conv.JClean (⟨20835, 17929, 2779819, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1293) : Conv.JClean (⟨20835, 17929, 2779820, 5782⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1295 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle134)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap134 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd134 a ha)) PRE_first_tail_x15_r0_body.zjc134

end Host.Load.Run.Tpl
end

section -- st134/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st134.bodyLast from PRE_first_tail_x15_r0_body.st134.s1 to PRE_first_tail_x15_r0_body.st134.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st134.F PRE_first_tail_x15_r0_body.st134.s1).run PRE_first_tail_x15_r0_body.st134.S1 = some (PRE_first_tail_x15_r0_body.st134.s2, PRE_first_tail_x15_r0_body.st134.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st134.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st134.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st134.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st134.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st134/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st134.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st134.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st134.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st134.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st134.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st134.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st134.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st134.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st134.s0 PRE_first_tail_x15_r0_body.st134.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st134.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st134.s1 PRE_first_tail_x15_r0_body.st134.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st134/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st134.bodyK0F from PRE_first_tail_x15_r0_body.st134.s0 to PRE_first_tail_x15_r0_body.st134.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st134.F (PRE_first_tail_x15_r0_body.st134.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st134.ks 0).getD 0) PRE_first_tail_x15_r0_body.st134.s0 PRE_first_tail_x15_r0_body.st134.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st134.s1, PRE_first_tail_x15_r0_body.st134.S1)
theorem PRE_first_tail_x15_r0_body.st134.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st134.F (PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st134.ks 0).getD 0) PRE_first_tail_x15_r0_body.st134.s0 PRE_first_tail_x15_r0_body.st134.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st134.s1, PRE_first_tail_x15_r0_body.st134.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st134.bodyOkLN_ok PRE_first_tail_x15_r0_body.st134.bodyK0F
end Host.Load.Run.Tpl
end

section -- st134/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st134.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st134.F (PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows) 98 PRE_first_tail_x15_r0_body.st134.s0 PRE_first_tail_x15_r0_body.st134.S0 = some (PRE_first_tail_x15_r0_body.st134.s1, PRE_first_tail_x15_r0_body.st134.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st134.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st134.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st134.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st134.F (PRE_first_tail_x15_r0_body.st134.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st134.s0
  S0 := PRE_first_tail_x15_r0_body.st134.S0
  s1 := PRE_first_tail_x15_r0_body.st134.s1
  S1 := PRE_first_tail_x15_r0_body.st134.S1
  s2 := PRE_first_tail_x15_r0_body.st134.s2
  S2 := PRE_first_tail_x15_r0_body.st134.S2
  n := 98
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st134.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st134.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st134.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st134.bodyHalt
  last := PRE_first_tail_x15_r0_body.st134.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st134.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 135 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1312` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa135` into the merged state
`PRE_first_tail_x15_r0_body.s1311`. -/

def PRE_first_tail_x15_r0_body.pl135 : List Nat := [2782403, 2781578, 2782409, 2782405, 2781580, 2782411]
def PRE_first_tail_x15_r0_body.nr135 : List Nat := [5885, 5884, 5860, 5868, 5873, 5878, 5883, 5857, 5858, 5859, 5866, 5867, 5855, 5862, 5863, 5864, 5865, 5861]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd135 : RData :=
  ⟨2781297, 2782446, Stage.setAll PTrie.nil [(2781291, 2782403), (2781292, 2781578), (2781293, 2782409), (2781294, 2782405), (2781295, 2781580), (2781296, 2782411)], Stage.setAll PTrie.nil [(20869, 20895), (20870, 20873), (20871, 20896)],
   20872, 20897, 17975, 17975, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5855, .ref 5885), (5856, .ref 5884), (5857, .ref 5860), (5858, .ref 5868), (5859, .ref 5873), (5860, .ref 5878), (5861, .ref 5883), (5862, .ref 5857), (5863, .ref 5858), (5864, .ref 5859), (5865, .ref 5866), (5866, .ref 5867), (5867, .ref 5855), (5868, .ref 5862), (5869, .ref 5863), (5870, .ref 5864), (5871, .ref 5865), (5872, .ref 5861)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa135 : Map :=
  Conv.Map.compact 2781291 2782446 5855 PRE_first_tail_x15_r0_body.pl135 (PRE_first_tail_x15_r0_body.nr135.map NumV.ref) PRE_first_tail_x15_r0_body.kd135.big
    PRE_first_tail_x15_r0_body.kd135.region PRE_first_tail_x15_r0_body.kd135.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws135 : List Nat := [3274, 3275, 3276, 3277, 3278, 3279, 3280, 3281, 3282, 3283, 3284, 3285, 3286, 3287, 3288, 3289, 3290, 3291]
noncomputable def PRE_first_tail_x15_r0_body.crs135 : List SymE := PRE_first_tail_x15_r0_body.nr135.map fun r => (nth? PRE_first_tail_x15_r0_body.S1311.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta135 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws135 PRE_first_tail_x15_r0_body.crs135
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB135 : List Nat := [2665, 2672646, 2673467, 2780465, 2781010, 2781266]

kernel_rfl PRE_first_tail_x15_r0_body.ctab135 : PRE_first_tail_x15_r0_body.S1312.tab = PRE_first_tail_x15_r0_body.S1310.tab ++ PRE_first_tail_x15_r0_body.cws135.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace135 : PRE_first_tail_x15_r0_body.s1312.trace = PRE_first_tail_x15_r0_body.s1310.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext135 : PRE_first_tail_x15_r0_body.s1312.next = 2781297
kernel_rfl PRE_first_tail_x15_r0_body.ccounters135 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nnext) = (20872, 17975)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa135.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.tokens.all (bSN 5873) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean135 : Conv.cleanListB 20872 131072 (fun r => Nat.ble 83488 r) PRE_first_tail_x15_r0_body.s1312
    (PRE_first_tail_x15_r0_body.wrB135 ++ (List.range 6).map (2781291 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs135 : bigsOutB 20872 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl135`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl135 : List Nat := [2665, 2672646, 2673467, 2780465, 2781010, 2781266, 2781291, 2781292, 2781293, 2781294, 2781295, 2781296]
def PRE_first_tail_x15_r0_body.clo135 : List Nat := [20849, 20862, 20868, 20869, 20870, 20871]
def PRE_first_tail_x15_r0_body.cln135 : List Nat := [17948, 17949, 17950, 17951, 17952, 17953, 17954, 17955, 17956, 17957, 17958, 17959, 17960, 17961, 17962, 17963, 17964, 17965, 17966, 17967, 17968, 17969, 17970, 17971, 17972, 17973, 17974]
def PRE_first_tail_x15_r0_body.cli135 : List Nat := [17948, 17949, 17950, 17951, 17952, 17953, 17954, 17955, 17956, 17957, 17958, 17959, 17960, 17961, 17962, 17963, 17964, 17965, 17966, 17967, 17968, 17969, 17970, 17971, 17972, 17973, 17974]
kernel_rfl PRE_first_tail_x15_r0_body.cheap135 : PRE_first_tail_x15_r0_body.s1312.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1310.heap (PRE_first_tail_x15_r0_body.cl135.filterMap fun a => (PRE_first_tail_x15_r0_body.s1312.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe135 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next PRE_first_tail_x15_r0_body.s1312.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP135 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp135 : Conv.suppListB PRE_first_tail_x15_r0_body.s1312 5873 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound135 : Conv.boundListB PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst135 : Conv.sstListB 5873 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cli135 = true

end Host.Load.Run.Tpl
end

section -- SiteCl135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA135 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd135 : (PRE_first_tail_x15_r0_body.clo135 ++ PRE_first_tail_x15_r0_body.cln135 ++ PRE_first_tail_x15_r0_body.cli135).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle135 : Conv.Cnt.leB (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck135 : Conv.ncleanListB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.cli135 = true
theorem PRE_first_tail_x15_r0_body.cncl135 (h : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) : Conv.NClean (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle135 PRE_first_tail_x15_r0_body.ckA135 PRE_first_tail_x15_r0_body.cobjsK135 PRE_first_tail_x15_r0_body.cnodesK135 PRE_first_tail_x15_r0_body.citemsK135 PRE_first_tail_x15_r0_body.cbd135 PRE_first_tail_x15_r0_body.cck135

end Host.Load.Run.Tpl
end

section -- SiteS135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 135 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc135 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P135 : LoadP := PRE_first_tail_x15_r0_body.Pc135.raise 17975
kernel_rfl PRE_first_tail_x15_r0_body.craise135 : Nat.ble PRE_first_tail_x15_r0_body.Pc135.N0 17975 = true
theorem PRE_first_tail_x15_r0_body.raised135 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc135 PRE_first_tail_x15_r0_body.P135 :=
  .inr ⟨17975, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise135, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_135 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_135 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi)
def PRE_first_tail_x15_r0_body.khinv135 : PTrie Nat := Stage.setAll PTrie.nil [(20895, 20869), (20873, 20870), (20896, 20871)]
def PRE_first_tail_x15_r0_body.kninv135 : PTrie Nat := Stage.setAll PTrie.nil [(17948, 17948), (17949, 17949), (17950, 17950), (17951, 17951), (17952, 17952), (17953, 17953), (17954, 17954), (17955, 17955), (17956, 17956), (17957, 17957), (17958, 17958), (17959, 17959), (17960, 17960), (17961, 17961), (17962, 17962), (17963, 17963), (17964, 17964), (17965, 17965), (17966, 17966), (17967, 17967), (17968, 17968), (17969, 17969), (17970, 17970), (17971, 17971), (17972, 17972), (17973, 17973), (17974, 17974)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS135 : List Nat := [20849, 20862, 20868, 20869, 20870, 20871, 20872, 20873, 20874, 20875, 20876, 20877, 20878, 20879, 20880, 20881, 20882, 20883, 20884, 20885, 20886, 20887, 20888, 20889, 20890, 20891, 20892, 20893, 20894, 20895, 20896]
def PRE_first_tail_x15_r0_body.cnS135 : List Nat := List.range' 17948 27
def PRE_first_tail_x15_r0_body.ciS135 : List Nat := [] ++ List.range' 17948 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0135 : PRE_first_tail_x15_r0_body.kd135.nh0 = PRE_first_tail_x15_r0_body.cx0_135.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1135 : PRE_first_tail_x15_r0_body.kd135.nh1 = PRE_first_tail_x15_r0_body.cx1_135.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0135 : PRE_first_tail_x15_r0_body.kd135.nn0 = PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1135 : PRE_first_tail_x15_r0_body.kd135.nn1 = PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo135 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P135.lo && Nat.ble PRE_first_tail_x15_r0_body.P135.lo PRE_first_tail_x15_r0_body.cx0_135.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P135.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P135.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt135 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_135.mlx.next PRE_first_tail_x15_r0_body.cx1_135.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband135 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P135.NL && Nat.ble PRE_first_tail_x15_r0_body.P135.NL PRE_first_tail_x15_r0_body.P135.N0 && Nat.ble PRE_first_tail_x15_r0_body.P135.N0 PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow135 : PRE_first_tail_x15_r0_body.kd135.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren135 : checkRenG PRE_first_tail_x15_r0_body.kd135.hnd PRE_first_tail_x15_r0_body.khinv135 (phB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband135 : PRE_first_tail_x15_r0_body.kd135.checkBand PRE_first_tail_x15_r0_body.P135.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos135 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd135.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren135 : checkRenG PRE_first_tail_x15_r0_body.kd135.node PRE_first_tail_x15_r0_body.kninv135 (pnB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P135.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd135.nodeF j) PRE_first_tail_x15_r0_body.cx1_135.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a135 : PRE_first_tail_x15_r0_body.cx0_135.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b135 : PRE_first_tail_x15_r0_body.cx0_135.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.pending = PRE_first_tail_x15_r0_body.cx0_135.mlx.pending.map PRE_first_tail_x15_r0_body.kappa135.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.errh = PRE_first_tail_x15_r0_body.cx0_135.mlx.errh.map PRE_first_tail_x15_r0_body.kappa135.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.files = PRE_first_tail_x15_r0_body.cx0_135.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.arch = PRE_first_tail_x15_r0_body.cx0_135.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_135.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.wired = PRE_first_tail_x15_r0_body.cx0_135.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost135 : PRE_first_tail_x15_r0_body.cx1_135.host = PRE_first_tail_x15_r0_body.cx0_135.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd135`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0135 : PRE_first_tail_x15_r0_body.kd135.n0 = 2781297
kernel_rfl PRE_first_tail_x15_r0_body.ckn1135 : PRE_first_tail_x15_r0_body.kd135.n1 = 2782446
kernel_rfl PRE_first_tail_x15_r0_body.ckheap135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.heap).all (fun x => Nat.ble 2781291 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl135 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd135.heap.get (2781291 + j) = nth? PRE_first_tail_x15_r0_body.pl135 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja135 : Nat.ble 2781291 2781291 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn135 : Nat.ble 5855 5855 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD135 : Nat.ble 2781291 PRE_first_tail_x15_r0_body.kd135.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn135 : Nat.ble 20869 PRE_first_tail_x15_r0_body.kd135.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn135 : Nat.ble 17948 PRE_first_tail_x15_r0_body.kd135.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb135 : Nat.ble 20869 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.heap).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.hnd).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (Nat.ble (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix135 : Conv.FixOld (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa135 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn135) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb135) PRE_first_tail_x15_r0_body.fheap135 PRE_first_tail_x15_r0_body.fhnd135 PRE_first_tail_x15_r0_body.fnode135
kernel_rfl PRE_first_tail_x15_r0_body.fcxn135 : (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn135 : (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0135 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_135.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_135.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I135 : PRE_first_tail_x15_r0_body.cx1_135.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS135.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd135 : (PRE_first_tail_x15_r0_body.clo135 ++ PRE_first_tail_x15_r0_body.cln135 ++ PRE_first_tail_x15_r0_body.cli135 ++ PRE_first_tail_x15_r0_body.cwS135 ++ PRE_first_tail_x15_r0_body.cnS135 ++ PRE_first_tail_x15_r0_body.ciS135).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW135 : PRE_first_tail_x15_r0_body.cwS135.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo135.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI135 : PRE_first_tail_x15_r0_body.ciS135.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli135.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN135 : PRE_first_tail_x15_r0_body.cnS135.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF135 : PRE_first_tail_x15_r0_body.cln135.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh135 : PRE_first_tail_x15_r0_body.clo135.all (handleOK PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135.lo PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo135 : PRE_first_tail_x15_r0_body.clo135.map (fun h => PRE_first_tail_x15_r0_body.cx1_135.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa135.handle h)) = PRE_first_tail_x15_r0_body.clo135.map (fun h => (PRE_first_tail_x15_r0_body.cx0_135.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa135.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok135 : PRE_first_tail_x15_r0_body.clo135.all (objOK PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135.NL PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd135 : PRE_first_tail_x15_r0_body.cln135.all (nodeOKF PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.P135 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp135 : ((PRE_first_tail_x15_r0_body.cln135.filter (fullB PRE_first_tail_x15_r0_body.P135))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_135.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa135.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln135.filter (fullB PRE_first_tail_x15_r0_body.P135))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_135.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa135.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI135 : incrB PRE_first_tail_x15_r0_body.kd135.nodeF (List.range' 17948 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK135 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all (fun k => Nat.ble 17948 k && Nat.blt k 17975) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL135 : (PRE_first_tail_x15_r0_body.cln135.filter (Nat.ble PRE_first_tail_x15_r0_body.P135.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd135.nodeF i) && (Nat.blt i 17975 || Nat.ble PRE_first_tail_x15_r0_body.kd135.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord135 : (PRE_first_tail_x15_r0_body.cln135.filter (Nat.ble PRE_first_tail_x15_r0_body.P135.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd135.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd135.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd135.nodeF j) (PRE_first_tail_x15_r0_body.kd135.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow135 PRE_first_tail_x15_r0_body.cnn1135 PRE_first_tail_x15_r0_body.fnordI135 PRE_first_tail_x15_r0_body.fnordK135 PRE_first_tail_x15_r0_body.fnordL135
kernel_rfl PRE_first_tail_x15_r0_body.fi135 : PRE_first_tail_x15_r0_body.cli135.all (pnB PRE_first_tail_x15_r0_body.cx0_135.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii135 : PRE_first_tail_x15_r0_body.cli135.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_135.mlx.items.get (PRE_first_tail_x15_r0_body.kappa135.node k) = (PRE_first_tail_x15_r0_body.cx0_135.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa135.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.kd135 PRE_first_tail_x15_r0_body.khinv135 PRE_first_tail_x15_r0_body.kninv135 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.cx1_135.mlx (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo135 PRE_first_tail_x15_r0_body.cln135 PRE_first_tail_x15_r0_body.cli135 PRE_first_tail_x15_r0_body.cwS135 PRE_first_tail_x15_r0_body.cnS135 PRE_first_tail_x15_r0_body.ciS135 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0135, PRE_first_tail_x15_r0_body.cnh1135, PRE_first_tail_x15_r0_body.cnn0135, PRE_first_tail_x15_r0_body.cnn1135, PRE_first_tail_x15_r0_body.cplo135, PRE_first_tail_x15_r0_body.ccnt135, PRE_first_tail_x15_r0_body.cnband135, PRE_first_tail_x15_r0_body.chbelow135, PRE_first_tail_x15_r0_body.chren135, PRE_first_tail_x15_r0_body.cband135, PRE_first_tail_x15_r0_body.cnh1pos135, PRE_first_tail_x15_r0_body.cnren135, PRE_first_tail_x15_r0_body.cnlow135, PRE_first_tail_x15_r0_body.cabs0a135, PRE_first_tail_x15_r0_body.cabs0b135, PRE_first_tail_x15_r0_body.ctok1135, PRE_first_tail_x15_r0_body.cpend135, PRE_first_tail_x15_r0_body.cerrh135, PRE_first_tail_x15_r0_body.cfiles135, PRE_first_tail_x15_r0_body.carch135, PRE_first_tail_x15_r0_body.csizes135, PRE_first_tail_x15_r0_body.cwired135, PRE_first_tail_x15_r0_body.cfix135, clean, PRE_first_tail_x15_r0_body.fcxn135, PRE_first_tail_x15_r0_body.fcnn135, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0135, PRE_first_tail_x15_r0_body.fnk135, PRE_first_tail_x15_r0_body.ckA135, PRE_first_tail_x15_r0_body.cobjsK135, PRE_first_tail_x15_r0_body.cnodesK135, PRE_first_tail_x15_r0_body.citemsK135, PRE_first_tail_x15_r0_body.f1A135, PRE_first_tail_x15_r0_body.f1O135, PRE_first_tail_x15_r0_body.f1N135, PRE_first_tail_x15_r0_body.f1I135, PRE_first_tail_x15_r0_body.fbd135, PRE_first_tail_x15_r0_body.fincW135, PRE_first_tail_x15_r0_body.fincI135, PRE_first_tail_x15_r0_body.fincN135, PRE_first_tail_x15_r0_body.flnF135, PRE_first_tail_x15_r0_body.fh135, PRE_first_tail_x15_r0_body.fo135, PRE_first_tail_x15_r0_body.fok135, PRE_first_tail_x15_r0_body.fnd135, PRE_first_tail_x15_r0_body.fp135, PRE_first_tail_x15_r0_body.fnord135, PRE_first_tail_x15_r0_body.fi135, PRE_first_tail_x15_r0_body.fii135⟩
theorem PRE_first_tail_x15_r0_body.cnshift135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx) : NShift PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.cx0_135 PRE_first_tail_x15_r0_body.cx1_135 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost135 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0135 PRE_first_tail_x15_r0_body.ckn1135 PRE_first_tail_x15_r0_body.ckheap135 PRE_first_tail_x15_r0_body.ckpl135)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1310.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1310.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1310.ffi) = some PRE_first_tail_x15_r0_body.fxC_135
kernel_rfl PRE_first_tail_x15_r0_body.okrC_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1310.ffi) = some PRE_first_tail_x15_r0_body.krC_135
noncomputable def PRE_first_tail_x15_r0_body.fx0_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.fx0_135
kernel_rfl PRE_first_tail_x15_r0_body.okr0_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1312.ffi) = some PRE_first_tail_x15_r0_body.kr0_135
noncomputable def PRE_first_tail_x15_r0_body.fx1_135 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1311.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_135 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1311.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_135 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1311.ffi) = some PRE_first_tail_x15_r0_body.fx1_135
kernel_rfl PRE_first_tail_x15_r0_body.okr1_135 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1311.ffi) = some PRE_first_tail_x15_r0_body.kr1_135
kernel_rfl PRE_first_tail_x15_r0_body.ff0135 : PRE_first_tail_x15_r0_body.fx0_135 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_135 (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_135.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1135 : PRE_first_tail_x15_r0_body.fx1_135 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_135 (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_135.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck135 : freedLB PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.fx0_135 PRE_first_tail_x15_r0_body.fx1_135 PRE_first_tail_x15_r0_body.clo135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0135 : PRE_first_tail_x15_r0_body.kr0_135.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.flags (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_135.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0135 : PRE_first_tail_x15_r0_body.kr0_135.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.targs (PRE_first_tail_x15_r0_body.clo135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_135.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1135 : PRE_first_tail_x15_r0_body.kr1_135.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.flags (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_135.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1135 : PRE_first_tail_x15_r0_body.kr1_135.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_135.targs (PRE_first_tail_x15_r0_body.cwS135.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_135.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck135 : krecLB PRE_first_tail_x15_r0_body.kappa135 5873 PRE_first_tail_x15_r0_body.cx0_135.mlx PRE_first_tail_x15_r0_body.kr0_135 PRE_first_tail_x15_r0_body.kr1_135 PRE_first_tail_x15_r0_body.clo135 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn135 : Nat.ble 5855 5873 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge135 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1311.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1312.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR135 : pendRegB PRE_first_tail_x15_r0_body.kappa135 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe135 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1312.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1311.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift135 (clean : Conv.NClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P135.NL) (cl : SSt (· < 5873) PRE_first_tail_x15_r0_body.cx0_135.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_135.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_135.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_135.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1310.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_135.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P135 5873 PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312.ffi PRE_first_tail_x15_r0_body.s1311.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift135 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue135, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp135 t ht),
    PRE_first_tail_x15_r0_body.cbridge135,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1312.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1311.ffi) (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_135 PRE_first_tail_x15_r0_body.ofx1_135 hobjC PRE_first_tail_x15_r0_body.ff0135 PRE_first_tail_x15_r0_body.ff1135 PRE_first_tail_x15_r0_body.ffck135,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1312.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1311.ffi) (PRE_first_tail_x15_r0_body.cfoot135 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_135 PRE_first_tail_x15_r0_body.okr1_135 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn135) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0135 PRE_first_tail_x15_r0_body.fkt0135 PRE_first_tail_x15_r0_body.fkf1135 PRE_first_tail_x15_r0_body.fkt1135 PRE_first_tail_x15_r0_body.fkck135,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0135 PRE_first_tail_x15_r0_body.cnh1135 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe135) PRE_first_tail_x15_r0_body.cpendR135⟩

end Host.Load.Run.Tpl
end

section -- st135/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st135 0
host_stream_state PRE_first_tail_x15_r0_body.st135 1
host_stream_state PRE_first_tail_x15_r0_body.st135 2
host_stream_state PRE_first_tail_x15_r0_body.st135 3
host_stream_state PRE_first_tail_x15_r0_body.st135 4
host_stream_state PRE_first_tail_x15_r0_body.st135 5
end Host.Load.Run.Tpl
end

section -- Site135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 135 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g135__g136` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1310`, the merged state `PRE_first_tail_x15_r0_body.s1311`,
the site template `PRE_first_tail_x15_r0_body.st135` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1312`: the merge.
The footprint's facts are in `SiteF135`, the compaction's in `SiteC135`, `SiteK135`, `SiteNa135`, `SiteNb135`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso135 : PRE_first_tail_x15_r0_body.st135.s0 = { PRE_first_tail_x15_r0_body.s1310 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs135 : List Frame := PRE_first_tail_x15_r0_body.s1310.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_135 : PRE_first_tail_x15_r0_body.S1310.tab.length = 5855
kernel_rfl PRE_first_tail_x15_r0_body.tab0_135 : PRE_first_tail_x15_r0_body.st135.S0.tab = PRE_first_tail_x15_r0_body.S1310.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws135 : List Nat := [3243, 3244, 3245, 3246, 3247, 3248, 3249, 3250, 3251, 3252, 3253, 3254, 3255, 3256, 3257, 3258, 3259, 3260, 3261, 3262, 3263, 3264, 3265, 3266, 3267, 3268, 3269, 3270, 3271, 3272, 3273]
kernel_rfl PRE_first_tail_x15_r0_body.fresh135 : (PRE_first_tail_x15_r0_body.S1310.tab.all fun e => PRE_first_tail_x15_r0_body.ws135.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1310.oracle.all fun q => PRE_first_tail_x15_r0_body.ws135.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab135 : PRE_first_tail_x15_r0_body.S1311.tab = PRE_first_tail_x15_r0_body.S1310.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws135
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen135 : PRE_first_tail_x15_r0_body.st135.S5.tab.length - PRE_first_tail_x15_r0_body.st135.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged135`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap135 : PRE_first_tail_x15_r0_body.s1311.heap = PRE_first_tail_x15_r0_body.st135.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext135 : PRE_first_tail_x15_r0_body.s1311.next = PRE_first_tail_x15_r0_body.st135.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl135 : PRE_first_tail_x15_r0_body.s1311.ctl = PRE_first_tail_x15_r0_body.st135.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack135 : PRE_first_tail_x15_r0_body.s1311.stack = PRE_first_tail_x15_r0_body.st135.s5.stack ++ PRE_first_tail_x15_r0_body.s1310.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs135 : PRE_first_tail_x15_r0_body.s1311.jobs = PRE_first_tail_x15_r0_body.st135.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi135 : PRE_first_tail_x15_r0_body.s1311.ffi = PRE_first_tail_x15_r0_body.st135.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace135 : PRE_first_tail_x15_r0_body.s1311.trace = PRE_first_tail_x15_r0_body.st135.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores135 : PRE_first_tail_x15_r0_body.s1311.stores = PRE_first_tail_x15_r0_body.st135.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 135 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived135 : PRE_first_tail_x15_r0_body.nr135.map (fun r => nth? PRE_first_tail_x15_r0_body.st135.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo135 : PRE_first_tail_x15_r0_body.nr135.all (Nat.ble 5855) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj135 : PRE_first_tail_x15_r0_body.cws135.all (fun c => !PRE_first_tail_x15_r0_body.ws135.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ135 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws135 PRE_first_tail_x15_r0_body.crs135 PRE_first_tail_x15_r0_body.ws135

end Host.Load.Run.Tpl
end

section -- st135/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st135`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st135.wrR : List (Nat × Nat) := [(2672646, 2672647), (2780465, 2780466), (2781010, 2781011), (2781266, 2781267)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st135.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st135.s5.heap PRE_first_tail_x15_r0_body.st135.wrR ++ freshOf PRE_first_tail_x15_r0_body.st135.s5.heap PRE_first_tail_x15_r0_body.st135.s0.next PRE_first_tail_x15_r0_body.st135.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st135.wr : List Nat := PRE_first_tail_x15_r0_body.st135.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st135.heapFoot : PRE_first_tail_x15_r0_body.st135.s5.heap = setAll PRE_first_tail_x15_r0_body.st135.s0.heap PRE_first_tail_x15_r0_body.st135.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st135.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st135.s0.next PRE_first_tail_x15_r0_body.st135.s5.next = true
theorem PRE_first_tail_x15_r0_body.st135.grows : PRE_first_tail_x15_r0_body.st135.s0.next ≤ PRE_first_tail_x15_r0_body.st135.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st135.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st135.wh : List Nat := [20849, 20862, 20868, 20869, 20870, 20871, 20872, 20873, 20874, 20875, 20876, 20877, 20878, 20879, 20880, 20881, 20882, 20883, 20884, 20885, 20886, 20887, 20888, 20889, 20890, 20891, 20892, 20893, 20894, 20895, 20896]
def PRE_first_tail_x15_r0_body.st135.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st135.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st135.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st135.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st135.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st135.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st135.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st135.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st135.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st135.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 135 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB135 : nodupT PRE_first_tail_x15_r0_body.st135.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup135 : PRE_first_tail_x15_r0_body.st135.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB135).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB135 : PRE_first_tail_x15_r0_body.st135.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound135 : ∀ b ∈ PRE_first_tail_x15_r0_body.st135.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB135 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr135 := PRE_first_tail_x15_r0_body.st135.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq135 : PRE_first_tail_x15_r0_body.st135.s5.trace = PRE_first_tail_x15_r0_body.trFr135 ++ PRE_first_tail_x15_r0_body.st135.s0.trace
theorem PRE_first_tail_x15_r0_body.trace135 : ∃ fr, PRE_first_tail_x15_r0_body.st135.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st135.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq135⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide135 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB135 : (PRE_first_tail_x15_r0_body.wide135.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st135.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix135 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide135, WFix Map.id (Present PRE_first_tail_x15_r0_body.st135.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB135 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 135 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1311`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO135 : PRE_first_tail_x15_r0_body.st135.S0.oracle = PRE_first_tail_x15_r0_body.st135.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B135 : PRE_first_tail_x15_r0_body.st135.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st135.s0.next || (PRE_first_tail_x15_r0_body.st135.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot135 : Conv.StageFoot PRE_first_tail_x15_r0_body.st135.wr PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st135.heapFoot PRE_first_tail_x15_r0_body.wrNodup135 PRE_first_tail_x15_r0_body.wrBound135 PRE_first_tail_x15_r0_body.wr0B135 PRE_first_tail_x15_r0_body.st135.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged135 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st135.F.S → PRE_first_tail_x15_r0_body.st135.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st135.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st135.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs135 PRE_first_tail_x15_r0_body.st135.wr PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.st135.s5 PRE_first_tail_x15_r0_body.st135.s0
      PRE_first_tail_x15_r0_body.st135.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st135.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1311 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso135 PRE_first_tail_x15_r0_body.stFoot135 PRE_first_tail_x15_r0_body.wrNodup135 PRE_first_tail_x15_r0_body.wrBound135 PRE_first_tail_x15_r0_body.trace135 PRE_first_tail_x15_r0_body.mheap135
    PRE_first_tail_x15_r0_body.mnext135 PRE_first_tail_x15_r0_body.mctl135 PRE_first_tail_x15_r0_body.mstack135 PRE_first_tail_x15_r0_body.mjobs135 PRE_first_tail_x15_r0_body.mffi135 PRE_first_tail_x15_r0_body.mtrace135 PRE_first_tail_x15_r0_body.mstores135 h

def PRE_first_tail_x15_r0_body.arrEl135_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE135_2665 : arrOf PRE_first_tail_x15_r0_body.s1311 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl135_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA135_2665 : isArrB PRE_first_tail_x15_r0_body.s1311 2665 = true
theorem PRE_first_tail_x15_r0_body.arr135_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1311.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl135_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE135_2665 PRE_first_tail_x15_r0_body.arrA135_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN135_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl135_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR135_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl135_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN135_2665

def PRE_first_tail_x15_r0_body.arrEl135_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE135_2673467 : arrOf PRE_first_tail_x15_r0_body.s1311 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl135_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA135_2673467 : isArrB PRE_first_tail_x15_r0_body.s1311 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr135_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1311.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl135_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE135_2673467 PRE_first_tail_x15_r0_body.arrA135_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN135_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl135_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR135_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl135_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN135_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k135 : isArrB PRE_first_tail_x15_r0_body.s1311 4910 = false
theorem PRE_first_tail_x15_r0_body.keep135 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1311 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k135 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr135_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl135_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ135
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 135 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1310`, the merged
state `PRE_first_tail_x15_r0_body.s1311`, the canonical state `PRE_first_tail_x15_r0_body.s1312`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl135 : PRE_first_tail_x15_r0_body.pl135.all (Nat.ble PRE_first_tail_x15_r0_body.s1310.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd135 : nodupT PRE_first_tail_x15_r0_body.pl135 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1135 : Nat.ble PRE_first_tail_x15_r0_body.s1310.next 2782446 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst135 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1310.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn135 : PRE_first_tail_x15_r0_body.s1312.next = PRE_first_tail_x15_r0_body.s1310.next + PRE_first_tail_x15_r0_body.pl135.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn135 : PRE_first_tail_x15_r0_body.s1311.next = 2782446
kernel_rfl PRE_first_tail_x15_r0_body.zgrow135 : Nat.ble PRE_first_tail_x15_r0_body.s1312.next PRE_first_tail_x15_r0_body.s1311.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh135 : PRE_first_tail_x15_r0_body.S1310.tab.all (fun e => PRE_first_tail_x15_r0_body.cws135.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd135 : nodupT PRE_first_tail_x15_r0_body.cws135 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi135 : PRE_first_tail_x15_r0_body.nr135.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1311.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt135 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1310.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg135_2665 : PRE_first_tail_x15_r0_body.s1312.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1312 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk135_2665 : (objOf PRE_first_tail_x15_r0_body.s1312 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm135_2665 : PRE_first_tail_x15_r0_body.s1311.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa135.obj (objOf PRE_first_tail_x15_r0_body.s1312 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1311 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg135_2673467 : PRE_first_tail_x15_r0_body.s1312.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1312 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk135_2673467 : (objOf PRE_first_tail_x15_r0_body.s1312 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm135_2673467 : PRE_first_tail_x15_r0_body.s1311.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa135.obj (objOf PRE_first_tail_x15_r0_body.s1312 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1311 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw135_4910 : (PRE_first_tail_x15_r0_body.s1312.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw135_2673472 : (PRE_first_tail_x15_r0_body.s1312.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw135_2673473 : (PRE_first_tail_x15_r0_body.s1312.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd135 : PRE_first_tail_x15_r0_body.cl135.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr135 : PRE_first_tail_x15_r0_body.st135.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1310.next || PRE_first_tail_x15_r0_body.cl135.contains b) = true
def PRE_first_tail_x15_r0_body.zl135 : List Nat := PRE_first_tail_x15_r0_body.cl135.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE135 : PRE_first_tail_x15_r0_body.zl135.map (fun a => PRE_first_tail_x15_r0_body.s1311.heap.get (PRE_first_tail_x15_r0_body.kappa135.a a)) = PRE_first_tail_x15_r0_body.zl135.map (fun a => (PRE_first_tail_x15_r0_body.s1312.heap.get a).map PRE_first_tail_x15_r0_body.kappa135.hobj)
theorem PRE_first_tail_x15_r0_body.zimg135 : HeapImg PRE_first_tail_x15_r0_body.kappa135 PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.s1311 PRE_first_tail_x15_r0_body.zl135 := PRE_first_tail_x15_r0_body.zimgE135
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl135 : PRE_first_tail_x15_r0_body.s1311.ctl = PRE_first_tail_x15_r0_body.kappa135.ctl PRE_first_tail_x15_r0_body.s1312.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack135 : PRE_first_tail_x15_r0_body.s1311.stack = PRE_first_tail_x15_r0_body.s1312.stack.map PRE_first_tail_x15_r0_body.kappa135.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs135 : PRE_first_tail_x15_r0_body.s1311.jobs = PRE_first_tail_x15_r0_body.s1312.jobs.map PRE_first_tail_x15_r0_body.kappa135.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores135 : PRE_first_tail_x15_r0_body.s1311.stores = PRE_first_tail_x15_r0_body.kappa135.stores PRE_first_tail_x15_r0_body.s1312.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots135 : checkRootsSupp PRE_first_tail_x15_r0_body.s1312 5873 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC135 : PRE_first_tail_x15_r0_body.S1310.tab.length + PRE_first_tail_x15_r0_body.cws135.length = 5873
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap135 : PRE_first_tail_x15_r0_body.kappa135 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1310.next 2782446 PRE_first_tail_x15_r0_body.S1310.tab.length PRE_first_tail_x15_r0_body.pl135 (PRE_first_tail_x15_r0_body.nr135.map NumV.ref) PRE_first_tail_x15_r0_body.kd135.big
  PRE_first_tail_x15_r0_body.kd135.region PRE_first_tail_x15_r0_body.kd135.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin135 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1312.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc135 : Conv.jcleanListB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.cl135 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB135 : noBigRootsP (fun i => !Conv.oldBigB (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1312.trace PRE_first_tail_x15_r0_body.s1312 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm135 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17948 = true
theorem PRE_first_tail_x15_r0_body.cjcl135 (h : Conv.JClean (⟨20869, 17948, 2781291, 5855⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1310) : Conv.JClean (⟨20872, 17975, 2781297, 5873⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1312 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle135)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap135 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd135 a ha)) PRE_first_tail_x15_r0_body.zjc135

end Host.Load.Run.Tpl
end

section -- st135/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st135.bodyLast from PRE_first_tail_x15_r0_body.st135.s4 to PRE_first_tail_x15_r0_body.st135.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st135.F PRE_first_tail_x15_r0_body.st135.s4).run PRE_first_tail_x15_r0_body.st135.S4 = some (PRE_first_tail_x15_r0_body.st135.s5, PRE_first_tail_x15_r0_body.st135.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st135.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st135.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st135.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st135.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st135/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st135.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st135.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st135.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st135.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st135.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st135.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st135.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st135.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st135.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st135.s4 PRE_first_tail_x15_r0_body.st135.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st135/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st135.bodyK0F from PRE_first_tail_x15_r0_body.st135.s0 to PRE_first_tail_x15_r0_body.st135.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 0).getD 0) PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s1, PRE_first_tail_x15_r0_body.st135.S1)
theorem PRE_first_tail_x15_r0_body.st135.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 0).getD 0) PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s1, PRE_first_tail_x15_r0_body.st135.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st135.bodyOkLN_ok PRE_first_tail_x15_r0_body.st135.bodyK0F
end Host.Load.Run.Tpl
end

section -- st135/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st135.bodyK1F from PRE_first_tail_x15_r0_body.st135.s1 to PRE_first_tail_x15_r0_body.st135.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 1).getD 0) PRE_first_tail_x15_r0_body.st135.s1 PRE_first_tail_x15_r0_body.st135.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s2, PRE_first_tail_x15_r0_body.st135.S2)
theorem PRE_first_tail_x15_r0_body.st135.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 1).getD 0) PRE_first_tail_x15_r0_body.st135.s1 PRE_first_tail_x15_r0_body.st135.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s2, PRE_first_tail_x15_r0_body.st135.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st135.bodyOkLN_ok PRE_first_tail_x15_r0_body.st135.bodyK1F
end Host.Load.Run.Tpl
end

section -- st135/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st135.bodyK2F from PRE_first_tail_x15_r0_body.st135.s2 to PRE_first_tail_x15_r0_body.st135.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 2).getD 0) PRE_first_tail_x15_r0_body.st135.s2 PRE_first_tail_x15_r0_body.st135.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s3, PRE_first_tail_x15_r0_body.st135.S3)
theorem PRE_first_tail_x15_r0_body.st135.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 2).getD 0) PRE_first_tail_x15_r0_body.st135.s2 PRE_first_tail_x15_r0_body.st135.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s3, PRE_first_tail_x15_r0_body.st135.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st135.bodyOkLN_ok PRE_first_tail_x15_r0_body.st135.bodyK2F
end Host.Load.Run.Tpl
end

section -- st135/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st135.bodyK3F from PRE_first_tail_x15_r0_body.st135.s3 to PRE_first_tail_x15_r0_body.st135.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 3).getD 0) PRE_first_tail_x15_r0_body.st135.s3 PRE_first_tail_x15_r0_body.st135.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s4, PRE_first_tail_x15_r0_body.st135.S4)
theorem PRE_first_tail_x15_r0_body.st135.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st135.ks 3).getD 0) PRE_first_tail_x15_r0_body.st135.s3 PRE_first_tail_x15_r0_body.st135.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st135.s4, PRE_first_tail_x15_r0_body.st135.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st135.bodyOkLN_ok PRE_first_tail_x15_r0_body.st135.bodyK3F
end Host.Load.Run.Tpl
end

section -- st135/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st135.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.S0 = some (PRE_first_tail_x15_r0_body.st135.s4, PRE_first_tail_x15_r0_body.st135.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st135.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st135.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st135.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st135.ks 3).getD 0) PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.s3 PRE_first_tail_x15_r0_body.st135.s4 PRE_first_tail_x15_r0_body.st135.S0 PRE_first_tail_x15_r0_body.st135.S3 PRE_first_tail_x15_r0_body.st135.S4 (runOk_trans PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st135.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st135.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st135.ks 2).getD 0) PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.s2 PRE_first_tail_x15_r0_body.st135.s3 PRE_first_tail_x15_r0_body.st135.S0 PRE_first_tail_x15_r0_body.st135.S2 PRE_first_tail_x15_r0_body.st135.S3 (runOk_trans PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st135.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st135.ks 1).getD 0) PRE_first_tail_x15_r0_body.st135.s0 PRE_first_tail_x15_r0_body.st135.s1 PRE_first_tail_x15_r0_body.st135.s2 PRE_first_tail_x15_r0_body.st135.S0 PRE_first_tail_x15_r0_body.st135.S1 PRE_first_tail_x15_r0_body.st135.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st135.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st135.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st135.F (PRE_first_tail_x15_r0_body.st135.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st135.s0
  S0 := PRE_first_tail_x15_r0_body.st135.S0
  s1 := PRE_first_tail_x15_r0_body.st135.s4
  S1 := PRE_first_tail_x15_r0_body.st135.S4
  s2 := PRE_first_tail_x15_r0_body.st135.s5
  S2 := PRE_first_tail_x15_r0_body.st135.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st135.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st135.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st135.bodyHalt
  last := PRE_first_tail_x15_r0_body.st135.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st135.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 136 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1320` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa136` into the merged state
`PRE_first_tail_x15_r0_body.s1319`. -/

def PRE_first_tail_x15_r0_body.pl136 : List Nat := []
def PRE_first_tail_x15_r0_body.nr136 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd136 : RData :=
  ⟨2781787, 2781789, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20885, 20885, 17988, 17988, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa136 : Map :=
  Conv.Map.compact 2781787 2781789 5894 PRE_first_tail_x15_r0_body.pl136 (PRE_first_tail_x15_r0_body.nr136.map NumV.ref) PRE_first_tail_x15_r0_body.kd136.big
    PRE_first_tail_x15_r0_body.kd136.region PRE_first_tail_x15_r0_body.kd136.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws136 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs136 : List SymE := PRE_first_tail_x15_r0_body.nr136.map fun r => (nth? PRE_first_tail_x15_r0_body.S1319.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta136 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws136 PRE_first_tail_x15_r0_body.crs136
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB136 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab136 : PRE_first_tail_x15_r0_body.S1320.tab = PRE_first_tail_x15_r0_body.S1318.tab ++ PRE_first_tail_x15_r0_body.cws136.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace136 : PRE_first_tail_x15_r0_body.s1320.trace = PRE_first_tail_x15_r0_body.s1318.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext136 : PRE_first_tail_x15_r0_body.s1320.next = 2781787
kernel_rfl PRE_first_tail_x15_r0_body.ccounters136 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nnext) = (20885, 17988)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa136.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.tokens.all (bSN 5894) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean136 : Conv.cleanListB 20885 131072 (fun r => Nat.ble 83540 r) PRE_first_tail_x15_r0_body.s1320
    (PRE_first_tail_x15_r0_body.wrB136 ++ (List.range 0).map (2781787 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs136 : bigsOutB 20885 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl136`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl136 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo136 : List Nat := []
def PRE_first_tail_x15_r0_body.cln136 : List Nat := []
def PRE_first_tail_x15_r0_body.cli136 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap136 : PRE_first_tail_x15_r0_body.s1320.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1318.heap (PRE_first_tail_x15_r0_body.cl136.filterMap fun a => (PRE_first_tail_x15_r0_body.s1320.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe136 : Nat.ble PRE_first_tail_x15_r0_body.s1318.next PRE_first_tail_x15_r0_body.s1320.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP136 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp136 : Conv.suppListB PRE_first_tail_x15_r0_body.s1320 5894 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound136 : Conv.boundListB PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst136 : Conv.sstListB 5894 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cli136 = true

end Host.Load.Run.Tpl
end

section -- SiteCl136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA136 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd136 : (PRE_first_tail_x15_r0_body.clo136 ++ PRE_first_tail_x15_r0_body.cln136 ++ PRE_first_tail_x15_r0_body.cli136).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle136 : Conv.Cnt.leB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck136 : Conv.ncleanListB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.cli136 = true
theorem PRE_first_tail_x15_r0_body.cncl136 (h : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle136 PRE_first_tail_x15_r0_body.ckA136 PRE_first_tail_x15_r0_body.cobjsK136 PRE_first_tail_x15_r0_body.cnodesK136 PRE_first_tail_x15_r0_body.citemsK136 PRE_first_tail_x15_r0_body.cbd136 PRE_first_tail_x15_r0_body.cck136

end Host.Load.Run.Tpl
end

section -- SiteS136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 136 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc136 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P136 : LoadP := PRE_first_tail_x15_r0_body.Pc136.raise 17988
kernel_rfl PRE_first_tail_x15_r0_body.craise136 : Nat.ble PRE_first_tail_x15_r0_body.Pc136.N0 17988 = true
theorem PRE_first_tail_x15_r0_body.raised136 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc136 PRE_first_tail_x15_r0_body.P136 :=
  .inr ⟨17988, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise136, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_136 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_136 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi)
def PRE_first_tail_x15_r0_body.khinv136 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv136 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS136 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS136 : List Nat := List.range' 17988 0
def PRE_first_tail_x15_r0_body.ciS136 : List Nat := [] ++ List.range' 17988 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0136 : PRE_first_tail_x15_r0_body.kd136.nh0 = PRE_first_tail_x15_r0_body.cx0_136.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1136 : PRE_first_tail_x15_r0_body.kd136.nh1 = PRE_first_tail_x15_r0_body.cx1_136.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0136 : PRE_first_tail_x15_r0_body.kd136.nn0 = PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1136 : PRE_first_tail_x15_r0_body.kd136.nn1 = PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo136 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P136.lo && Nat.ble PRE_first_tail_x15_r0_body.P136.lo PRE_first_tail_x15_r0_body.cx0_136.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P136.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P136.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt136 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_136.mlx.next PRE_first_tail_x15_r0_body.cx1_136.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband136 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P136.NL && Nat.ble PRE_first_tail_x15_r0_body.P136.NL PRE_first_tail_x15_r0_body.P136.N0 && Nat.ble PRE_first_tail_x15_r0_body.P136.N0 PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow136 : PRE_first_tail_x15_r0_body.kd136.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren136 : checkRenG PRE_first_tail_x15_r0_body.kd136.hnd PRE_first_tail_x15_r0_body.khinv136 (phB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband136 : PRE_first_tail_x15_r0_body.kd136.checkBand PRE_first_tail_x15_r0_body.P136.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos136 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd136.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren136 : checkRenG PRE_first_tail_x15_r0_body.kd136.node PRE_first_tail_x15_r0_body.kninv136 (pnB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P136.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd136.nodeF j) PRE_first_tail_x15_r0_body.cx1_136.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a136 : PRE_first_tail_x15_r0_body.cx0_136.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b136 : PRE_first_tail_x15_r0_body.cx0_136.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.pending = PRE_first_tail_x15_r0_body.cx0_136.mlx.pending.map PRE_first_tail_x15_r0_body.kappa136.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.errh = PRE_first_tail_x15_r0_body.cx0_136.mlx.errh.map PRE_first_tail_x15_r0_body.kappa136.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.files = PRE_first_tail_x15_r0_body.cx0_136.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.arch = PRE_first_tail_x15_r0_body.cx0_136.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_136.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.wired = PRE_first_tail_x15_r0_body.cx0_136.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost136 : PRE_first_tail_x15_r0_body.cx1_136.host = PRE_first_tail_x15_r0_body.cx0_136.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd136`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0136 : PRE_first_tail_x15_r0_body.kd136.n0 = 2781787
kernel_rfl PRE_first_tail_x15_r0_body.ckn1136 : PRE_first_tail_x15_r0_body.kd136.n1 = 2781789
kernel_rfl PRE_first_tail_x15_r0_body.ckheap136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.heap).all (fun x => Nat.ble 2781787 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl136 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd136.heap.get (2781787 + j) = nth? PRE_first_tail_x15_r0_body.pl136 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja136 : Nat.ble 2781787 2781787 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn136 : Nat.ble 5894 5894 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD136 : Nat.ble 2781787 PRE_first_tail_x15_r0_body.kd136.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn136 : Nat.ble 20885 PRE_first_tail_x15_r0_body.kd136.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn136 : Nat.ble 17988 PRE_first_tail_x15_r0_body.kd136.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb136 : Nat.ble 20885 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.heap).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.hnd).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (Nat.ble (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix136 : Conv.FixOld (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa136 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn136) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb136) PRE_first_tail_x15_r0_body.fheap136 PRE_first_tail_x15_r0_body.fhnd136 PRE_first_tail_x15_r0_body.fnode136
kernel_rfl PRE_first_tail_x15_r0_body.fcxn136 : (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn136 : (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0136 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_136.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_136.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I136 : PRE_first_tail_x15_r0_body.cx1_136.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS136.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd136 : (PRE_first_tail_x15_r0_body.clo136 ++ PRE_first_tail_x15_r0_body.cln136 ++ PRE_first_tail_x15_r0_body.cli136 ++ PRE_first_tail_x15_r0_body.cwS136 ++ PRE_first_tail_x15_r0_body.cnS136 ++ PRE_first_tail_x15_r0_body.ciS136).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW136 : PRE_first_tail_x15_r0_body.cwS136.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo136.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI136 : PRE_first_tail_x15_r0_body.ciS136.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli136.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN136 : PRE_first_tail_x15_r0_body.cnS136.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF136 : PRE_first_tail_x15_r0_body.cln136.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh136 : PRE_first_tail_x15_r0_body.clo136.all (handleOK PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136.lo PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo136 : PRE_first_tail_x15_r0_body.clo136.map (fun h => PRE_first_tail_x15_r0_body.cx1_136.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa136.handle h)) = PRE_first_tail_x15_r0_body.clo136.map (fun h => (PRE_first_tail_x15_r0_body.cx0_136.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa136.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok136 : PRE_first_tail_x15_r0_body.clo136.all (objOK PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136.NL PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd136 : PRE_first_tail_x15_r0_body.cln136.all (nodeOKF PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.P136 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp136 : ((PRE_first_tail_x15_r0_body.cln136.filter (fullB PRE_first_tail_x15_r0_body.P136))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_136.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa136.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln136.filter (fullB PRE_first_tail_x15_r0_body.P136))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_136.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa136.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI136 : incrB PRE_first_tail_x15_r0_body.kd136.nodeF (List.range' 17988 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK136 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all (fun k => Nat.ble 17988 k && Nat.blt k 17988) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL136 : (PRE_first_tail_x15_r0_body.cln136.filter (Nat.ble PRE_first_tail_x15_r0_body.P136.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd136.nodeF i) && (Nat.blt i 17988 || Nat.ble PRE_first_tail_x15_r0_body.kd136.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord136 : (PRE_first_tail_x15_r0_body.cln136.filter (Nat.ble PRE_first_tail_x15_r0_body.P136.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd136.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd136.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd136.nodeF j) (PRE_first_tail_x15_r0_body.kd136.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow136 PRE_first_tail_x15_r0_body.cnn1136 PRE_first_tail_x15_r0_body.fnordI136 PRE_first_tail_x15_r0_body.fnordK136 PRE_first_tail_x15_r0_body.fnordL136
kernel_rfl PRE_first_tail_x15_r0_body.fi136 : PRE_first_tail_x15_r0_body.cli136.all (pnB PRE_first_tail_x15_r0_body.cx0_136.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii136 : PRE_first_tail_x15_r0_body.cli136.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_136.mlx.items.get (PRE_first_tail_x15_r0_body.kappa136.node k) = (PRE_first_tail_x15_r0_body.cx0_136.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa136.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.kd136 PRE_first_tail_x15_r0_body.khinv136 PRE_first_tail_x15_r0_body.kninv136 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.cx1_136.mlx (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo136 PRE_first_tail_x15_r0_body.cln136 PRE_first_tail_x15_r0_body.cli136 PRE_first_tail_x15_r0_body.cwS136 PRE_first_tail_x15_r0_body.cnS136 PRE_first_tail_x15_r0_body.ciS136 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0136, PRE_first_tail_x15_r0_body.cnh1136, PRE_first_tail_x15_r0_body.cnn0136, PRE_first_tail_x15_r0_body.cnn1136, PRE_first_tail_x15_r0_body.cplo136, PRE_first_tail_x15_r0_body.ccnt136, PRE_first_tail_x15_r0_body.cnband136, PRE_first_tail_x15_r0_body.chbelow136, PRE_first_tail_x15_r0_body.chren136, PRE_first_tail_x15_r0_body.cband136, PRE_first_tail_x15_r0_body.cnh1pos136, PRE_first_tail_x15_r0_body.cnren136, PRE_first_tail_x15_r0_body.cnlow136, PRE_first_tail_x15_r0_body.cabs0a136, PRE_first_tail_x15_r0_body.cabs0b136, PRE_first_tail_x15_r0_body.ctok1136, PRE_first_tail_x15_r0_body.cpend136, PRE_first_tail_x15_r0_body.cerrh136, PRE_first_tail_x15_r0_body.cfiles136, PRE_first_tail_x15_r0_body.carch136, PRE_first_tail_x15_r0_body.csizes136, PRE_first_tail_x15_r0_body.cwired136, PRE_first_tail_x15_r0_body.cfix136, clean, PRE_first_tail_x15_r0_body.fcxn136, PRE_first_tail_x15_r0_body.fcnn136, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0136, PRE_first_tail_x15_r0_body.fnk136, PRE_first_tail_x15_r0_body.ckA136, PRE_first_tail_x15_r0_body.cobjsK136, PRE_first_tail_x15_r0_body.cnodesK136, PRE_first_tail_x15_r0_body.citemsK136, PRE_first_tail_x15_r0_body.f1A136, PRE_first_tail_x15_r0_body.f1O136, PRE_first_tail_x15_r0_body.f1N136, PRE_first_tail_x15_r0_body.f1I136, PRE_first_tail_x15_r0_body.fbd136, PRE_first_tail_x15_r0_body.fincW136, PRE_first_tail_x15_r0_body.fincI136, PRE_first_tail_x15_r0_body.fincN136, PRE_first_tail_x15_r0_body.flnF136, PRE_first_tail_x15_r0_body.fh136, PRE_first_tail_x15_r0_body.fo136, PRE_first_tail_x15_r0_body.fok136, PRE_first_tail_x15_r0_body.fnd136, PRE_first_tail_x15_r0_body.fp136, PRE_first_tail_x15_r0_body.fnord136, PRE_first_tail_x15_r0_body.fi136, PRE_first_tail_x15_r0_body.fii136⟩
theorem PRE_first_tail_x15_r0_body.cnshift136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx) : NShift PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.cx0_136 PRE_first_tail_x15_r0_body.cx1_136 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost136 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0136 PRE_first_tail_x15_r0_body.ckn1136 PRE_first_tail_x15_r0_body.ckheap136 PRE_first_tail_x15_r0_body.ckpl136)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1318.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1318.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1318.ffi) = some PRE_first_tail_x15_r0_body.fxC_136
kernel_rfl PRE_first_tail_x15_r0_body.okrC_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1318.ffi) = some PRE_first_tail_x15_r0_body.krC_136
noncomputable def PRE_first_tail_x15_r0_body.fx0_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1320.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1320.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1320.ffi) = some PRE_first_tail_x15_r0_body.fx0_136
kernel_rfl PRE_first_tail_x15_r0_body.okr0_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1320.ffi) = some PRE_first_tail_x15_r0_body.kr0_136
noncomputable def PRE_first_tail_x15_r0_body.fx1_136 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1319.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_136 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1319.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_136 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1319.ffi) = some PRE_first_tail_x15_r0_body.fx1_136
kernel_rfl PRE_first_tail_x15_r0_body.okr1_136 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1319.ffi) = some PRE_first_tail_x15_r0_body.kr1_136
kernel_rfl PRE_first_tail_x15_r0_body.ff0136 : PRE_first_tail_x15_r0_body.fx0_136 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_136 (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_136.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1136 : PRE_first_tail_x15_r0_body.fx1_136 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_136 (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_136.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck136 : freedLB PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.fx0_136 PRE_first_tail_x15_r0_body.fx1_136 PRE_first_tail_x15_r0_body.clo136 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0136 : PRE_first_tail_x15_r0_body.kr0_136.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.flags (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_136.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0136 : PRE_first_tail_x15_r0_body.kr0_136.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.targs (PRE_first_tail_x15_r0_body.clo136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_136.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1136 : PRE_first_tail_x15_r0_body.kr1_136.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.flags (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_136.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1136 : PRE_first_tail_x15_r0_body.kr1_136.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_136.targs (PRE_first_tail_x15_r0_body.cwS136.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_136.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck136 : krecLB PRE_first_tail_x15_r0_body.kappa136 5894 PRE_first_tail_x15_r0_body.cx0_136.mlx PRE_first_tail_x15_r0_body.kr0_136 PRE_first_tail_x15_r0_body.kr1_136 PRE_first_tail_x15_r0_body.clo136 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn136 : Nat.ble 5894 5894 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge136 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1319.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1320.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR136 : pendRegB PRE_first_tail_x15_r0_body.kappa136 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe136 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1320.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1319.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift136 (clean : Conv.NClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P136.NL) (cl : SSt (· < 5894) PRE_first_tail_x15_r0_body.cx0_136.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_136.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_136.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_136.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1318.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_136.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P136 5894 PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320.ffi PRE_first_tail_x15_r0_body.s1319.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift136 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue136, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp136 t ht),
    PRE_first_tail_x15_r0_body.cbridge136,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1320.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1319.ffi) (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_136 PRE_first_tail_x15_r0_body.ofx1_136 hobjC PRE_first_tail_x15_r0_body.ff0136 PRE_first_tail_x15_r0_body.ff1136 PRE_first_tail_x15_r0_body.ffck136,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1320.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1319.ffi) (PRE_first_tail_x15_r0_body.cfoot136 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_136 PRE_first_tail_x15_r0_body.okr1_136 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn136) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0136 PRE_first_tail_x15_r0_body.fkt0136 PRE_first_tail_x15_r0_body.fkf1136 PRE_first_tail_x15_r0_body.fkt1136 PRE_first_tail_x15_r0_body.fkck136,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0136 PRE_first_tail_x15_r0_body.cnh1136 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe136) PRE_first_tail_x15_r0_body.cpendR136⟩

end Host.Load.Run.Tpl
end

section -- st136/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st136 0
host_stream_state PRE_first_tail_x15_r0_body.st136 1
host_stream_state PRE_first_tail_x15_r0_body.st136 2
end Host.Load.Run.Tpl
end

section -- Site136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 136 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g136__g137` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1318`, the merged state `PRE_first_tail_x15_r0_body.s1319`,
the site template `PRE_first_tail_x15_r0_body.st136` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1320`: the merge.
The footprint's facts are in `SiteF136`, the compaction's in `SiteC136`, `SiteK136`, `SiteNa136`, `SiteNb136`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso136 : PRE_first_tail_x15_r0_body.st136.s0 = { PRE_first_tail_x15_r0_body.s1318 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs136 : List Frame := PRE_first_tail_x15_r0_body.s1318.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_136 : PRE_first_tail_x15_r0_body.S1318.tab.length = 5894
kernel_rfl PRE_first_tail_x15_r0_body.tab0_136 : PRE_first_tail_x15_r0_body.st136.S0.tab = PRE_first_tail_x15_r0_body.S1318.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws136 : List Nat := [3292, 3293]
kernel_rfl PRE_first_tail_x15_r0_body.fresh136 : (PRE_first_tail_x15_r0_body.S1318.tab.all fun e => PRE_first_tail_x15_r0_body.ws136.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1318.oracle.all fun q => PRE_first_tail_x15_r0_body.ws136.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab136 : PRE_first_tail_x15_r0_body.S1319.tab = PRE_first_tail_x15_r0_body.S1318.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws136
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen136 : PRE_first_tail_x15_r0_body.st136.S2.tab.length - PRE_first_tail_x15_r0_body.st136.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged136`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap136 : PRE_first_tail_x15_r0_body.s1319.heap = PRE_first_tail_x15_r0_body.st136.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext136 : PRE_first_tail_x15_r0_body.s1319.next = PRE_first_tail_x15_r0_body.st136.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl136 : PRE_first_tail_x15_r0_body.s1319.ctl = PRE_first_tail_x15_r0_body.st136.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack136 : PRE_first_tail_x15_r0_body.s1319.stack = PRE_first_tail_x15_r0_body.st136.s2.stack ++ PRE_first_tail_x15_r0_body.s1318.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs136 : PRE_first_tail_x15_r0_body.s1319.jobs = PRE_first_tail_x15_r0_body.st136.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi136 : PRE_first_tail_x15_r0_body.s1319.ffi = PRE_first_tail_x15_r0_body.st136.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace136 : PRE_first_tail_x15_r0_body.s1319.trace = PRE_first_tail_x15_r0_body.st136.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores136 : PRE_first_tail_x15_r0_body.s1319.stores = PRE_first_tail_x15_r0_body.st136.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 136 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived136 : PRE_first_tail_x15_r0_body.nr136.map (fun r => nth? PRE_first_tail_x15_r0_body.st136.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo136 : PRE_first_tail_x15_r0_body.nr136.all (Nat.ble 5894) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj136 : PRE_first_tail_x15_r0_body.cws136.all (fun c => !PRE_first_tail_x15_r0_body.ws136.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ136 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws136 PRE_first_tail_x15_r0_body.crs136 PRE_first_tail_x15_r0_body.ws136

end Host.Load.Run.Tpl
end

section -- st136/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st136`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st136.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st136.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st136.s2.heap PRE_first_tail_x15_r0_body.st136.wrR ++ freshOf PRE_first_tail_x15_r0_body.st136.s2.heap PRE_first_tail_x15_r0_body.st136.s0.next PRE_first_tail_x15_r0_body.st136.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st136.wr : List Nat := PRE_first_tail_x15_r0_body.st136.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st136.heapFoot : PRE_first_tail_x15_r0_body.st136.s2.heap = setAll PRE_first_tail_x15_r0_body.st136.s0.heap PRE_first_tail_x15_r0_body.st136.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st136.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st136.s0.next PRE_first_tail_x15_r0_body.st136.s2.next = true
theorem PRE_first_tail_x15_r0_body.st136.grows : PRE_first_tail_x15_r0_body.st136.s0.next ≤ PRE_first_tail_x15_r0_body.st136.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st136.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st136.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st136.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st136.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st136.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st136.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st136.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st136.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st136.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st136.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st136.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st136.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 136 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB136 : nodupT PRE_first_tail_x15_r0_body.st136.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup136 : PRE_first_tail_x15_r0_body.st136.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB136).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB136 : PRE_first_tail_x15_r0_body.st136.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound136 : ∀ b ∈ PRE_first_tail_x15_r0_body.st136.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB136 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr136 := PRE_first_tail_x15_r0_body.st136.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq136 : PRE_first_tail_x15_r0_body.st136.s2.trace = PRE_first_tail_x15_r0_body.trFr136 ++ PRE_first_tail_x15_r0_body.st136.s0.trace
theorem PRE_first_tail_x15_r0_body.trace136 : ∃ fr, PRE_first_tail_x15_r0_body.st136.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st136.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq136⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide136 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB136 : (PRE_first_tail_x15_r0_body.wide136.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st136.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix136 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide136, WFix Map.id (Present PRE_first_tail_x15_r0_body.st136.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB136 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 136 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1319`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO136 : PRE_first_tail_x15_r0_body.st136.S0.oracle = PRE_first_tail_x15_r0_body.st136.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B136 : PRE_first_tail_x15_r0_body.st136.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st136.s0.next || (PRE_first_tail_x15_r0_body.st136.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot136 : Conv.StageFoot PRE_first_tail_x15_r0_body.st136.wr PRE_first_tail_x15_r0_body.st136.s0 PRE_first_tail_x15_r0_body.st136.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st136.heapFoot PRE_first_tail_x15_r0_body.wrNodup136 PRE_first_tail_x15_r0_body.wrBound136 PRE_first_tail_x15_r0_body.wr0B136 PRE_first_tail_x15_r0_body.st136.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged136 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st136.F.S → PRE_first_tail_x15_r0_body.st136.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st136.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st136.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs136 PRE_first_tail_x15_r0_body.st136.wr PRE_first_tail_x15_r0_body.s1318 PRE_first_tail_x15_r0_body.st136.s2 PRE_first_tail_x15_r0_body.st136.s0
      PRE_first_tail_x15_r0_body.st136.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st136.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1319 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso136 PRE_first_tail_x15_r0_body.stFoot136 PRE_first_tail_x15_r0_body.wrNodup136 PRE_first_tail_x15_r0_body.wrBound136 PRE_first_tail_x15_r0_body.trace136 PRE_first_tail_x15_r0_body.mheap136
    PRE_first_tail_x15_r0_body.mnext136 PRE_first_tail_x15_r0_body.mctl136 PRE_first_tail_x15_r0_body.mstack136 PRE_first_tail_x15_r0_body.mjobs136 PRE_first_tail_x15_r0_body.mffi136 PRE_first_tail_x15_r0_body.mtrace136 PRE_first_tail_x15_r0_body.mstores136 h

def PRE_first_tail_x15_r0_body.arrEl136_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE136_2665 : arrOf PRE_first_tail_x15_r0_body.s1319 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl136_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA136_2665 : isArrB PRE_first_tail_x15_r0_body.s1319 2665 = true
theorem PRE_first_tail_x15_r0_body.arr136_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1319.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl136_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE136_2665 PRE_first_tail_x15_r0_body.arrA136_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN136_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl136_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR136_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl136_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN136_2665

def PRE_first_tail_x15_r0_body.arrEl136_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE136_2673467 : arrOf PRE_first_tail_x15_r0_body.s1319 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl136_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA136_2673467 : isArrB PRE_first_tail_x15_r0_body.s1319 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr136_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1319.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl136_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE136_2673467 PRE_first_tail_x15_r0_body.arrA136_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN136_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl136_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR136_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl136_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN136_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k136 : isArrB PRE_first_tail_x15_r0_body.s1319 4910 = false
theorem PRE_first_tail_x15_r0_body.keep136 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1319 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k136 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr136_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl136_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ136
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 136 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1318`, the merged
state `PRE_first_tail_x15_r0_body.s1319`, the canonical state `PRE_first_tail_x15_r0_body.s1320`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl136 : PRE_first_tail_x15_r0_body.pl136.all (Nat.ble PRE_first_tail_x15_r0_body.s1318.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd136 : nodupT PRE_first_tail_x15_r0_body.pl136 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1136 : Nat.ble PRE_first_tail_x15_r0_body.s1318.next 2781789 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst136 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1318.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn136 : PRE_first_tail_x15_r0_body.s1320.next = PRE_first_tail_x15_r0_body.s1318.next + PRE_first_tail_x15_r0_body.pl136.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn136 : PRE_first_tail_x15_r0_body.s1319.next = 2781789
kernel_rfl PRE_first_tail_x15_r0_body.zgrow136 : Nat.ble PRE_first_tail_x15_r0_body.s1320.next PRE_first_tail_x15_r0_body.s1319.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh136 : PRE_first_tail_x15_r0_body.S1318.tab.all (fun e => PRE_first_tail_x15_r0_body.cws136.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd136 : nodupT PRE_first_tail_x15_r0_body.cws136 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi136 : PRE_first_tail_x15_r0_body.nr136.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1319.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt136 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1318.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg136_2665 : PRE_first_tail_x15_r0_body.s1320.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1320 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk136_2665 : (objOf PRE_first_tail_x15_r0_body.s1320 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm136_2665 : PRE_first_tail_x15_r0_body.s1319.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa136.obj (objOf PRE_first_tail_x15_r0_body.s1320 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1319 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg136_2673467 : PRE_first_tail_x15_r0_body.s1320.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1320 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk136_2673467 : (objOf PRE_first_tail_x15_r0_body.s1320 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm136_2673467 : PRE_first_tail_x15_r0_body.s1319.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa136.obj (objOf PRE_first_tail_x15_r0_body.s1320 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1319 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw136_4910 : (PRE_first_tail_x15_r0_body.s1320.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw136_2673472 : (PRE_first_tail_x15_r0_body.s1320.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw136_2673473 : (PRE_first_tail_x15_r0_body.s1320.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd136 : PRE_first_tail_x15_r0_body.cl136.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr136 : PRE_first_tail_x15_r0_body.st136.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1318.next || PRE_first_tail_x15_r0_body.cl136.contains b) = true
def PRE_first_tail_x15_r0_body.zl136 : List Nat := PRE_first_tail_x15_r0_body.cl136.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE136 : PRE_first_tail_x15_r0_body.zl136.map (fun a => PRE_first_tail_x15_r0_body.s1319.heap.get (PRE_first_tail_x15_r0_body.kappa136.a a)) = PRE_first_tail_x15_r0_body.zl136.map (fun a => (PRE_first_tail_x15_r0_body.s1320.heap.get a).map PRE_first_tail_x15_r0_body.kappa136.hobj)
theorem PRE_first_tail_x15_r0_body.zimg136 : HeapImg PRE_first_tail_x15_r0_body.kappa136 PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.s1319 PRE_first_tail_x15_r0_body.zl136 := PRE_first_tail_x15_r0_body.zimgE136
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl136 : PRE_first_tail_x15_r0_body.s1319.ctl = PRE_first_tail_x15_r0_body.kappa136.ctl PRE_first_tail_x15_r0_body.s1320.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack136 : PRE_first_tail_x15_r0_body.s1319.stack = PRE_first_tail_x15_r0_body.s1320.stack.map PRE_first_tail_x15_r0_body.kappa136.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs136 : PRE_first_tail_x15_r0_body.s1319.jobs = PRE_first_tail_x15_r0_body.s1320.jobs.map PRE_first_tail_x15_r0_body.kappa136.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores136 : PRE_first_tail_x15_r0_body.s1319.stores = PRE_first_tail_x15_r0_body.kappa136.stores PRE_first_tail_x15_r0_body.s1320.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots136 : checkRootsSupp PRE_first_tail_x15_r0_body.s1320 5894 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC136 : PRE_first_tail_x15_r0_body.S1318.tab.length + PRE_first_tail_x15_r0_body.cws136.length = 5894
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap136 : PRE_first_tail_x15_r0_body.kappa136 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1318.next 2781789 PRE_first_tail_x15_r0_body.S1318.tab.length PRE_first_tail_x15_r0_body.pl136 (PRE_first_tail_x15_r0_body.nr136.map NumV.ref) PRE_first_tail_x15_r0_body.kd136.big
  PRE_first_tail_x15_r0_body.kd136.region PRE_first_tail_x15_r0_body.kd136.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin136 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1320.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc136 : Conv.jcleanListB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1320 PRE_first_tail_x15_r0_body.cl136 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB136 : noBigRootsP (fun i => !Conv.oldBigB (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1320.trace PRE_first_tail_x15_r0_body.s1320 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm136 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17988 = true
theorem PRE_first_tail_x15_r0_body.cjcl136 (h : Conv.JClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1318) : Conv.JClean (⟨20885, 17988, 2781787, 5894⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1320 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle136)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap136 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd136 a ha)) PRE_first_tail_x15_r0_body.zjc136

end Host.Load.Run.Tpl
end

section -- st136/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st136.bodyLast from PRE_first_tail_x15_r0_body.st136.s1 to PRE_first_tail_x15_r0_body.st136.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st136.F PRE_first_tail_x15_r0_body.st136.s1).run PRE_first_tail_x15_r0_body.st136.S1 = some (PRE_first_tail_x15_r0_body.st136.s2, PRE_first_tail_x15_r0_body.st136.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st136.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st136.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st136.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st136.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st136/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st136.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st136.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st136.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st136.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st136.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st136.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st136.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st136.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st136.s0 PRE_first_tail_x15_r0_body.st136.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st136.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st136.s1 PRE_first_tail_x15_r0_body.st136.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st136/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st136.bodyK0F from PRE_first_tail_x15_r0_body.st136.s0 to PRE_first_tail_x15_r0_body.st136.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st136.F (PRE_first_tail_x15_r0_body.st136.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st136.ks 0).getD 0) PRE_first_tail_x15_r0_body.st136.s0 PRE_first_tail_x15_r0_body.st136.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st136.s1, PRE_first_tail_x15_r0_body.st136.S1)
theorem PRE_first_tail_x15_r0_body.st136.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st136.F (PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st136.ks 0).getD 0) PRE_first_tail_x15_r0_body.st136.s0 PRE_first_tail_x15_r0_body.st136.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st136.s1, PRE_first_tail_x15_r0_body.st136.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st136.bodyOkLN_ok PRE_first_tail_x15_r0_body.st136.bodyK0F
end Host.Load.Run.Tpl
end

section -- st136/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st136.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st136.F (PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st136.s0 PRE_first_tail_x15_r0_body.st136.S0 = some (PRE_first_tail_x15_r0_body.st136.s1, PRE_first_tail_x15_r0_body.st136.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st136.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st136.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st136.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st136.F (PRE_first_tail_x15_r0_body.st136.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st136.s0
  S0 := PRE_first_tail_x15_r0_body.st136.S0
  s1 := PRE_first_tail_x15_r0_body.st136.s1
  S1 := PRE_first_tail_x15_r0_body.st136.S1
  s2 := PRE_first_tail_x15_r0_body.st136.s2
  S2 := PRE_first_tail_x15_r0_body.st136.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st136.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st136.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st136.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st136.bodyHalt
  last := PRE_first_tail_x15_r0_body.st136.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st136.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 137 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1324` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa137` into the merged state
`PRE_first_tail_x15_r0_body.s1323`. -/

def PRE_first_tail_x15_r0_body.pl137 : List Nat := [2782094]
def PRE_first_tail_x15_r0_body.nr137 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd137 : RData :=
  ⟨2782076, 2782095, Stage.setAll PTrie.nil [(2782075, 2782094)], Stage.setAll PTrie.nil [],
   20892, 20892, 17992, 17992, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa137 : Map :=
  Conv.Map.compact 2782075 2782095 5911 PRE_first_tail_x15_r0_body.pl137 (PRE_first_tail_x15_r0_body.nr137.map NumV.ref) PRE_first_tail_x15_r0_body.kd137.big
    PRE_first_tail_x15_r0_body.kd137.region PRE_first_tail_x15_r0_body.kd137.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws137 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs137 : List SymE := PRE_first_tail_x15_r0_body.nr137.map fun r => (nth? PRE_first_tail_x15_r0_body.S1323.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta137 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws137 PRE_first_tail_x15_r0_body.crs137
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB137 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab137 : PRE_first_tail_x15_r0_body.S1324.tab = PRE_first_tail_x15_r0_body.S1322.tab ++ PRE_first_tail_x15_r0_body.cws137.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace137 : PRE_first_tail_x15_r0_body.s1324.trace = PRE_first_tail_x15_r0_body.s1322.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext137 : PRE_first_tail_x15_r0_body.s1324.next = 2782076
kernel_rfl PRE_first_tail_x15_r0_body.ccounters137 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.nnext) = (20892, 17992)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1323.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa137.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.tokens.all (bSN 5911) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean137 : Conv.cleanListB 20892 131072 (fun r => Nat.ble 83568 r) PRE_first_tail_x15_r0_body.s1324
    (PRE_first_tail_x15_r0_body.wrB137 ++ (List.range 1).map (2782075 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs137 : bigsOutB 20892 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl137`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl137 : List Nat := [2665, 2673467, 2782075]
def PRE_first_tail_x15_r0_body.clo137 : List Nat := []
def PRE_first_tail_x15_r0_body.cln137 : List Nat := []
def PRE_first_tail_x15_r0_body.cli137 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap137 : PRE_first_tail_x15_r0_body.s1324.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1322.heap (PRE_first_tail_x15_r0_body.cl137.filterMap fun a => (PRE_first_tail_x15_r0_body.s1324.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe137 : Nat.ble PRE_first_tail_x15_r0_body.s1322.next PRE_first_tail_x15_r0_body.s1324.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP137 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.cl137 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp137 : Conv.suppListB PRE_first_tail_x15_r0_body.s1324 5911 PRE_first_tail_x15_r0_body.cl137 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound137 : Conv.boundListB PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.cl137 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln137.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli137.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst137 : Conv.sstListB 5911 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx PRE_first_tail_x15_r0_body.cln137 PRE_first_tail_x15_r0_body.clo137 PRE_first_tail_x15_r0_body.cli137 = true

end Host.Load.Run.Tpl
end

section -- SiteCl137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA137 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd137 : (PRE_first_tail_x15_r0_body.clo137 ++ PRE_first_tail_x15_r0_body.cln137 ++ PRE_first_tail_x15_r0_body.cli137).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle137 : Conv.Cnt.leB (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck137 : Conv.ncleanListB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx PRE_first_tail_x15_r0_body.clo137 PRE_first_tail_x15_r0_body.cln137 PRE_first_tail_x15_r0_body.cli137 = true
theorem PRE_first_tail_x15_r0_body.cncl137 (h : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx) : Conv.NClean (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle137 PRE_first_tail_x15_r0_body.ckA137 PRE_first_tail_x15_r0_body.cobjsK137 PRE_first_tail_x15_r0_body.cnodesK137 PRE_first_tail_x15_r0_body.citemsK137 PRE_first_tail_x15_r0_body.cbd137 PRE_first_tail_x15_r0_body.cck137

end Host.Load.Run.Tpl
end

section -- SiteS137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 137 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc137 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P137 : LoadP := PRE_first_tail_x15_r0_body.Pc137.raise 17992
kernel_rfl PRE_first_tail_x15_r0_body.craise137 : Nat.ble PRE_first_tail_x15_r0_body.Pc137.N0 17992 = true
theorem PRE_first_tail_x15_r0_body.raised137 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc137 PRE_first_tail_x15_r0_body.P137 :=
  .inr ⟨17992, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise137, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_137 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_137 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1323.ffi)
def PRE_first_tail_x15_r0_body.khinv137 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv137 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS137 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS137 : List Nat := List.range' 17992 0
def PRE_first_tail_x15_r0_body.ciS137 : List Nat := [] ++ List.range' 17992 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0137 : PRE_first_tail_x15_r0_body.kd137.nh0 = PRE_first_tail_x15_r0_body.cx0_137.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1137 : PRE_first_tail_x15_r0_body.kd137.nh1 = PRE_first_tail_x15_r0_body.cx1_137.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0137 : PRE_first_tail_x15_r0_body.kd137.nn0 = PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1137 : PRE_first_tail_x15_r0_body.kd137.nn1 = PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo137 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P137.lo && Nat.ble PRE_first_tail_x15_r0_body.P137.lo PRE_first_tail_x15_r0_body.cx0_137.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P137.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P137.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt137 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_137.mlx.next PRE_first_tail_x15_r0_body.cx1_137.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband137 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P137.NL && Nat.ble PRE_first_tail_x15_r0_body.P137.NL PRE_first_tail_x15_r0_body.P137.N0 && Nat.ble PRE_first_tail_x15_r0_body.P137.N0 PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow137 : PRE_first_tail_x15_r0_body.kd137.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren137 : checkRenG PRE_first_tail_x15_r0_body.kd137.hnd PRE_first_tail_x15_r0_body.khinv137 (phB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband137 : PRE_first_tail_x15_r0_body.kd137.checkBand PRE_first_tail_x15_r0_body.P137.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos137 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd137.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren137 : checkRenG PRE_first_tail_x15_r0_body.kd137.node PRE_first_tail_x15_r0_body.kninv137 (pnB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P137.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd137.nodeF j) PRE_first_tail_x15_r0_body.cx1_137.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a137 : PRE_first_tail_x15_r0_body.cx0_137.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b137 : PRE_first_tail_x15_r0_body.cx0_137.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.pending = PRE_first_tail_x15_r0_body.cx0_137.mlx.pending.map PRE_first_tail_x15_r0_body.kappa137.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.errh = PRE_first_tail_x15_r0_body.cx0_137.mlx.errh.map PRE_first_tail_x15_r0_body.kappa137.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.files = PRE_first_tail_x15_r0_body.cx0_137.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.arch = PRE_first_tail_x15_r0_body.cx0_137.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_137.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.wired = PRE_first_tail_x15_r0_body.cx0_137.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost137 : PRE_first_tail_x15_r0_body.cx1_137.host = PRE_first_tail_x15_r0_body.cx0_137.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd137`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0137 : PRE_first_tail_x15_r0_body.kd137.n0 = 2782076
kernel_rfl PRE_first_tail_x15_r0_body.ckn1137 : PRE_first_tail_x15_r0_body.kd137.n1 = 2782095
kernel_rfl PRE_first_tail_x15_r0_body.ckheap137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.heap).all (fun x => Nat.ble 2782075 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl137 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd137.heap.get (2782075 + j) = nth? PRE_first_tail_x15_r0_body.pl137 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja137 : Nat.ble 2782075 2782075 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn137 : Nat.ble 5911 5911 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD137 : Nat.ble 2782075 PRE_first_tail_x15_r0_body.kd137.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn137 : Nat.ble 20892 PRE_first_tail_x15_r0_body.kd137.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn137 : Nat.ble 17992 PRE_first_tail_x15_r0_body.kd137.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb137 : Nat.ble 20892 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.heap).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.hnd).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (Nat.ble (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix137 : Conv.FixOld (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa137 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn137) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb137) PRE_first_tail_x15_r0_body.fheap137 PRE_first_tail_x15_r0_body.fhnd137 PRE_first_tail_x15_r0_body.fnode137
kernel_rfl PRE_first_tail_x15_r0_body.fcxn137 : (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn137 : (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0137 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_137.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_137.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I137 : PRE_first_tail_x15_r0_body.cx1_137.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS137.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd137 : (PRE_first_tail_x15_r0_body.clo137 ++ PRE_first_tail_x15_r0_body.cln137 ++ PRE_first_tail_x15_r0_body.cli137 ++ PRE_first_tail_x15_r0_body.cwS137 ++ PRE_first_tail_x15_r0_body.cnS137 ++ PRE_first_tail_x15_r0_body.ciS137).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW137 : PRE_first_tail_x15_r0_body.cwS137.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo137.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI137 : PRE_first_tail_x15_r0_body.ciS137.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli137.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN137 : PRE_first_tail_x15_r0_body.cnS137.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF137 : PRE_first_tail_x15_r0_body.cln137.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh137 : PRE_first_tail_x15_r0_body.clo137.all (handleOK PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137.lo PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo137 : PRE_first_tail_x15_r0_body.clo137.map (fun h => PRE_first_tail_x15_r0_body.cx1_137.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa137.handle h)) = PRE_first_tail_x15_r0_body.clo137.map (fun h => (PRE_first_tail_x15_r0_body.cx0_137.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa137.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok137 : PRE_first_tail_x15_r0_body.clo137.all (objOK PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137.NL PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd137 : PRE_first_tail_x15_r0_body.cln137.all (nodeOKF PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.P137 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp137 : ((PRE_first_tail_x15_r0_body.cln137.filter (fullB PRE_first_tail_x15_r0_body.P137))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_137.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa137.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln137.filter (fullB PRE_first_tail_x15_r0_body.P137))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_137.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa137.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI137 : incrB PRE_first_tail_x15_r0_body.kd137.nodeF (List.range' 17992 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK137 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all (fun k => Nat.ble 17992 k && Nat.blt k 17992) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL137 : (PRE_first_tail_x15_r0_body.cln137.filter (Nat.ble PRE_first_tail_x15_r0_body.P137.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd137.nodeF i) && (Nat.blt i 17992 || Nat.ble PRE_first_tail_x15_r0_body.kd137.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord137 : (PRE_first_tail_x15_r0_body.cln137.filter (Nat.ble PRE_first_tail_x15_r0_body.P137.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd137.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd137.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd137.nodeF j) (PRE_first_tail_x15_r0_body.kd137.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow137 PRE_first_tail_x15_r0_body.cnn1137 PRE_first_tail_x15_r0_body.fnordI137 PRE_first_tail_x15_r0_body.fnordK137 PRE_first_tail_x15_r0_body.fnordL137
kernel_rfl PRE_first_tail_x15_r0_body.fi137 : PRE_first_tail_x15_r0_body.cli137.all (pnB PRE_first_tail_x15_r0_body.cx0_137.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii137 : PRE_first_tail_x15_r0_body.cli137.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_137.mlx.items.get (PRE_first_tail_x15_r0_body.kappa137.node k) = (PRE_first_tail_x15_r0_body.cx0_137.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa137.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.kd137 PRE_first_tail_x15_r0_body.khinv137 PRE_first_tail_x15_r0_body.kninv137 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.cx1_137.mlx (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo137 PRE_first_tail_x15_r0_body.cln137 PRE_first_tail_x15_r0_body.cli137 PRE_first_tail_x15_r0_body.cwS137 PRE_first_tail_x15_r0_body.cnS137 PRE_first_tail_x15_r0_body.ciS137 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0137, PRE_first_tail_x15_r0_body.cnh1137, PRE_first_tail_x15_r0_body.cnn0137, PRE_first_tail_x15_r0_body.cnn1137, PRE_first_tail_x15_r0_body.cplo137, PRE_first_tail_x15_r0_body.ccnt137, PRE_first_tail_x15_r0_body.cnband137, PRE_first_tail_x15_r0_body.chbelow137, PRE_first_tail_x15_r0_body.chren137, PRE_first_tail_x15_r0_body.cband137, PRE_first_tail_x15_r0_body.cnh1pos137, PRE_first_tail_x15_r0_body.cnren137, PRE_first_tail_x15_r0_body.cnlow137, PRE_first_tail_x15_r0_body.cabs0a137, PRE_first_tail_x15_r0_body.cabs0b137, PRE_first_tail_x15_r0_body.ctok1137, PRE_first_tail_x15_r0_body.cpend137, PRE_first_tail_x15_r0_body.cerrh137, PRE_first_tail_x15_r0_body.cfiles137, PRE_first_tail_x15_r0_body.carch137, PRE_first_tail_x15_r0_body.csizes137, PRE_first_tail_x15_r0_body.cwired137, PRE_first_tail_x15_r0_body.cfix137, clean, PRE_first_tail_x15_r0_body.fcxn137, PRE_first_tail_x15_r0_body.fcnn137, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0137, PRE_first_tail_x15_r0_body.fnk137, PRE_first_tail_x15_r0_body.ckA137, PRE_first_tail_x15_r0_body.cobjsK137, PRE_first_tail_x15_r0_body.cnodesK137, PRE_first_tail_x15_r0_body.citemsK137, PRE_first_tail_x15_r0_body.f1A137, PRE_first_tail_x15_r0_body.f1O137, PRE_first_tail_x15_r0_body.f1N137, PRE_first_tail_x15_r0_body.f1I137, PRE_first_tail_x15_r0_body.fbd137, PRE_first_tail_x15_r0_body.fincW137, PRE_first_tail_x15_r0_body.fincI137, PRE_first_tail_x15_r0_body.fincN137, PRE_first_tail_x15_r0_body.flnF137, PRE_first_tail_x15_r0_body.fh137, PRE_first_tail_x15_r0_body.fo137, PRE_first_tail_x15_r0_body.fok137, PRE_first_tail_x15_r0_body.fnd137, PRE_first_tail_x15_r0_body.fp137, PRE_first_tail_x15_r0_body.fnord137, PRE_first_tail_x15_r0_body.fi137, PRE_first_tail_x15_r0_body.fii137⟩
theorem PRE_first_tail_x15_r0_body.cnshift137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx) : NShift PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.cx0_137 PRE_first_tail_x15_r0_body.cx1_137 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost137 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0137 PRE_first_tail_x15_r0_body.ckn1137 PRE_first_tail_x15_r0_body.ckheap137 PRE_first_tail_x15_r0_body.ckpl137)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1322.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1322.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1322.ffi) = some PRE_first_tail_x15_r0_body.fxC_137
kernel_rfl PRE_first_tail_x15_r0_body.okrC_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1322.ffi) = some PRE_first_tail_x15_r0_body.krC_137
noncomputable def PRE_first_tail_x15_r0_body.fx0_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1324.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1324.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1324.ffi) = some PRE_first_tail_x15_r0_body.fx0_137
kernel_rfl PRE_first_tail_x15_r0_body.okr0_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1324.ffi) = some PRE_first_tail_x15_r0_body.kr0_137
noncomputable def PRE_first_tail_x15_r0_body.fx1_137 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1323.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_137 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1323.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_137 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1323.ffi) = some PRE_first_tail_x15_r0_body.fx1_137
kernel_rfl PRE_first_tail_x15_r0_body.okr1_137 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1323.ffi) = some PRE_first_tail_x15_r0_body.kr1_137
kernel_rfl PRE_first_tail_x15_r0_body.ff0137 : PRE_first_tail_x15_r0_body.fx0_137 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_137 (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_137.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1137 : PRE_first_tail_x15_r0_body.fx1_137 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_137 (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_137.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck137 : freedLB PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.fx0_137 PRE_first_tail_x15_r0_body.fx1_137 PRE_first_tail_x15_r0_body.clo137 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0137 : PRE_first_tail_x15_r0_body.kr0_137.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.flags (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_137.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0137 : PRE_first_tail_x15_r0_body.kr0_137.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.targs (PRE_first_tail_x15_r0_body.clo137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_137.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1137 : PRE_first_tail_x15_r0_body.kr1_137.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.flags (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_137.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1137 : PRE_first_tail_x15_r0_body.kr1_137.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_137.targs (PRE_first_tail_x15_r0_body.cwS137.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_137.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck137 : krecLB PRE_first_tail_x15_r0_body.kappa137 5911 PRE_first_tail_x15_r0_body.cx0_137.mlx PRE_first_tail_x15_r0_body.kr0_137 PRE_first_tail_x15_r0_body.kr1_137 PRE_first_tail_x15_r0_body.clo137 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn137 : Nat.ble 5911 5911 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge137 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1323.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1324.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR137 : pendRegB PRE_first_tail_x15_r0_body.kappa137 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe137 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1324.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1323.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift137 (clean : Conv.NClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P137.NL) (cl : SSt (· < 5911) PRE_first_tail_x15_r0_body.cx0_137.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_137.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_137.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_137.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1322.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_137.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P137 5911 PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1324.ffi PRE_first_tail_x15_r0_body.s1323.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift137 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue137, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp137 t ht),
    PRE_first_tail_x15_r0_body.cbridge137,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1324.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1323.ffi) (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_137 PRE_first_tail_x15_r0_body.ofx1_137 hobjC PRE_first_tail_x15_r0_body.ff0137 PRE_first_tail_x15_r0_body.ff1137 PRE_first_tail_x15_r0_body.ffck137,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1324.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1323.ffi) (PRE_first_tail_x15_r0_body.cfoot137 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_137 PRE_first_tail_x15_r0_body.okr1_137 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn137) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0137 PRE_first_tail_x15_r0_body.fkt0137 PRE_first_tail_x15_r0_body.fkf1137 PRE_first_tail_x15_r0_body.fkt1137 PRE_first_tail_x15_r0_body.fkck137,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0137 PRE_first_tail_x15_r0_body.cnh1137 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe137) PRE_first_tail_x15_r0_body.cpendR137⟩

end Host.Load.Run.Tpl
end

section -- st137/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st137 0
host_stream_state PRE_first_tail_x15_r0_body.st137 1
host_stream_state PRE_first_tail_x15_r0_body.st137 2
end Host.Load.Run.Tpl
end

section -- Site137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 137 of chain `PRE_first_tail_x15_r0_body`: `plan__g137__g138` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1322`, the merged state `PRE_first_tail_x15_r0_body.s1323`,
the site template `PRE_first_tail_x15_r0_body.st137` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1324`: the merge.
The footprint's facts are in `SiteF137`, the compaction's in `SiteC137`, `SiteK137`, `SiteNa137`, `SiteNb137`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso137 : PRE_first_tail_x15_r0_body.st137.s0 = { PRE_first_tail_x15_r0_body.s1322 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs137 : List Frame := PRE_first_tail_x15_r0_body.s1322.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_137 : PRE_first_tail_x15_r0_body.S1322.tab.length = 5911
kernel_rfl PRE_first_tail_x15_r0_body.tab0_137 : PRE_first_tail_x15_r0_body.st137.S0.tab = PRE_first_tail_x15_r0_body.S1322.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws137 : List Nat := [3294, 3295, 3296, 3297, 3298, 3299, 3300, 3301, 3302]
kernel_rfl PRE_first_tail_x15_r0_body.fresh137 : (PRE_first_tail_x15_r0_body.S1322.tab.all fun e => PRE_first_tail_x15_r0_body.ws137.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1322.oracle.all fun q => PRE_first_tail_x15_r0_body.ws137.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab137 : PRE_first_tail_x15_r0_body.S1323.tab = PRE_first_tail_x15_r0_body.S1322.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws137
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen137 : PRE_first_tail_x15_r0_body.st137.S2.tab.length - PRE_first_tail_x15_r0_body.st137.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged137`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap137 : PRE_first_tail_x15_r0_body.s1323.heap = PRE_first_tail_x15_r0_body.st137.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext137 : PRE_first_tail_x15_r0_body.s1323.next = PRE_first_tail_x15_r0_body.st137.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl137 : PRE_first_tail_x15_r0_body.s1323.ctl = PRE_first_tail_x15_r0_body.st137.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack137 : PRE_first_tail_x15_r0_body.s1323.stack = PRE_first_tail_x15_r0_body.st137.s2.stack ++ PRE_first_tail_x15_r0_body.s1322.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs137 : PRE_first_tail_x15_r0_body.s1323.jobs = PRE_first_tail_x15_r0_body.st137.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi137 : PRE_first_tail_x15_r0_body.s1323.ffi = PRE_first_tail_x15_r0_body.st137.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace137 : PRE_first_tail_x15_r0_body.s1323.trace = PRE_first_tail_x15_r0_body.st137.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores137 : PRE_first_tail_x15_r0_body.s1323.stores = PRE_first_tail_x15_r0_body.st137.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 137 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived137 : PRE_first_tail_x15_r0_body.nr137.map (fun r => nth? PRE_first_tail_x15_r0_body.st137.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo137 : PRE_first_tail_x15_r0_body.nr137.all (Nat.ble 5911) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj137 : PRE_first_tail_x15_r0_body.cws137.all (fun c => !PRE_first_tail_x15_r0_body.ws137.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ137 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws137 PRE_first_tail_x15_r0_body.crs137 PRE_first_tail_x15_r0_body.ws137

end Host.Load.Run.Tpl
end

section -- st137/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st137`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st137.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st137.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st137.s2.heap PRE_first_tail_x15_r0_body.st137.wrR ++ freshOf PRE_first_tail_x15_r0_body.st137.s2.heap PRE_first_tail_x15_r0_body.st137.s0.next PRE_first_tail_x15_r0_body.st137.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st137.wr : List Nat := PRE_first_tail_x15_r0_body.st137.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st137.heapFoot : PRE_first_tail_x15_r0_body.st137.s2.heap = setAll PRE_first_tail_x15_r0_body.st137.s0.heap PRE_first_tail_x15_r0_body.st137.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st137.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st137.s0.next PRE_first_tail_x15_r0_body.st137.s2.next = true
theorem PRE_first_tail_x15_r0_body.st137.grows : PRE_first_tail_x15_r0_body.st137.s0.next ≤ PRE_first_tail_x15_r0_body.st137.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st137.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st137.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st137.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st137.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st137.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st137.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st137.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st137.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st137.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st137.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st137.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st137.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 137 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB137 : nodupT PRE_first_tail_x15_r0_body.st137.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup137 : PRE_first_tail_x15_r0_body.st137.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB137).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB137 : PRE_first_tail_x15_r0_body.st137.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound137 : ∀ b ∈ PRE_first_tail_x15_r0_body.st137.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB137 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr137 := PRE_first_tail_x15_r0_body.st137.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq137 : PRE_first_tail_x15_r0_body.st137.s2.trace = PRE_first_tail_x15_r0_body.trFr137 ++ PRE_first_tail_x15_r0_body.st137.s0.trace
theorem PRE_first_tail_x15_r0_body.trace137 : ∃ fr, PRE_first_tail_x15_r0_body.st137.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st137.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq137⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide137 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB137 : (PRE_first_tail_x15_r0_body.wide137.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st137.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix137 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide137, WFix Map.id (Present PRE_first_tail_x15_r0_body.st137.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB137 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 137 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1323`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO137 : PRE_first_tail_x15_r0_body.st137.S0.oracle = PRE_first_tail_x15_r0_body.st137.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B137 : PRE_first_tail_x15_r0_body.st137.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st137.s0.next || (PRE_first_tail_x15_r0_body.st137.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot137 : Conv.StageFoot PRE_first_tail_x15_r0_body.st137.wr PRE_first_tail_x15_r0_body.st137.s0 PRE_first_tail_x15_r0_body.st137.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st137.heapFoot PRE_first_tail_x15_r0_body.wrNodup137 PRE_first_tail_x15_r0_body.wrBound137 PRE_first_tail_x15_r0_body.wr0B137 PRE_first_tail_x15_r0_body.st137.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged137 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st137.F.S → PRE_first_tail_x15_r0_body.st137.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st137.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st137.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs137 PRE_first_tail_x15_r0_body.st137.wr PRE_first_tail_x15_r0_body.s1322 PRE_first_tail_x15_r0_body.st137.s2 PRE_first_tail_x15_r0_body.st137.s0
      PRE_first_tail_x15_r0_body.st137.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st137.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1323 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso137 PRE_first_tail_x15_r0_body.stFoot137 PRE_first_tail_x15_r0_body.wrNodup137 PRE_first_tail_x15_r0_body.wrBound137 PRE_first_tail_x15_r0_body.trace137 PRE_first_tail_x15_r0_body.mheap137
    PRE_first_tail_x15_r0_body.mnext137 PRE_first_tail_x15_r0_body.mctl137 PRE_first_tail_x15_r0_body.mstack137 PRE_first_tail_x15_r0_body.mjobs137 PRE_first_tail_x15_r0_body.mffi137 PRE_first_tail_x15_r0_body.mtrace137 PRE_first_tail_x15_r0_body.mstores137 h

def PRE_first_tail_x15_r0_body.arrEl137_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE137_2665 : arrOf PRE_first_tail_x15_r0_body.s1323 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl137_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA137_2665 : isArrB PRE_first_tail_x15_r0_body.s1323 2665 = true
theorem PRE_first_tail_x15_r0_body.arr137_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1323.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl137_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE137_2665 PRE_first_tail_x15_r0_body.arrA137_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN137_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl137_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR137_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl137_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN137_2665

def PRE_first_tail_x15_r0_body.arrEl137_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE137_2673467 : arrOf PRE_first_tail_x15_r0_body.s1323 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl137_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA137_2673467 : isArrB PRE_first_tail_x15_r0_body.s1323 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr137_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1323.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl137_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE137_2673467 PRE_first_tail_x15_r0_body.arrA137_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN137_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl137_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR137_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl137_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN137_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k137 : isArrB PRE_first_tail_x15_r0_body.s1323 4910 = false
theorem PRE_first_tail_x15_r0_body.keep137 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1323 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k137 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr137_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl137_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ137
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 137 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1322`, the merged
state `PRE_first_tail_x15_r0_body.s1323`, the canonical state `PRE_first_tail_x15_r0_body.s1324`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl137 : PRE_first_tail_x15_r0_body.pl137.all (Nat.ble PRE_first_tail_x15_r0_body.s1322.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd137 : nodupT PRE_first_tail_x15_r0_body.pl137 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1137 : Nat.ble PRE_first_tail_x15_r0_body.s1322.next 2782095 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst137 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1322.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn137 : PRE_first_tail_x15_r0_body.s1324.next = PRE_first_tail_x15_r0_body.s1322.next + PRE_first_tail_x15_r0_body.pl137.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn137 : PRE_first_tail_x15_r0_body.s1323.next = 2782095
kernel_rfl PRE_first_tail_x15_r0_body.zgrow137 : Nat.ble PRE_first_tail_x15_r0_body.s1324.next PRE_first_tail_x15_r0_body.s1323.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh137 : PRE_first_tail_x15_r0_body.S1322.tab.all (fun e => PRE_first_tail_x15_r0_body.cws137.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd137 : nodupT PRE_first_tail_x15_r0_body.cws137 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi137 : PRE_first_tail_x15_r0_body.nr137.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1323.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt137 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1322.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg137_2665 : PRE_first_tail_x15_r0_body.s1324.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1324 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk137_2665 : (objOf PRE_first_tail_x15_r0_body.s1324 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm137_2665 : PRE_first_tail_x15_r0_body.s1323.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa137.obj (objOf PRE_first_tail_x15_r0_body.s1324 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1323 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg137_2673467 : PRE_first_tail_x15_r0_body.s1324.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1324 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk137_2673467 : (objOf PRE_first_tail_x15_r0_body.s1324 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm137_2673467 : PRE_first_tail_x15_r0_body.s1323.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa137.obj (objOf PRE_first_tail_x15_r0_body.s1324 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1323 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw137_4910 : (PRE_first_tail_x15_r0_body.s1324.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw137_2673472 : (PRE_first_tail_x15_r0_body.s1324.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw137_2673473 : (PRE_first_tail_x15_r0_body.s1324.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd137 : PRE_first_tail_x15_r0_body.cl137.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr137 : PRE_first_tail_x15_r0_body.st137.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1322.next || PRE_first_tail_x15_r0_body.cl137.contains b) = true
def PRE_first_tail_x15_r0_body.zl137 : List Nat := PRE_first_tail_x15_r0_body.cl137.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE137 : PRE_first_tail_x15_r0_body.zl137.map (fun a => PRE_first_tail_x15_r0_body.s1323.heap.get (PRE_first_tail_x15_r0_body.kappa137.a a)) = PRE_first_tail_x15_r0_body.zl137.map (fun a => (PRE_first_tail_x15_r0_body.s1324.heap.get a).map PRE_first_tail_x15_r0_body.kappa137.hobj)
theorem PRE_first_tail_x15_r0_body.zimg137 : HeapImg PRE_first_tail_x15_r0_body.kappa137 PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.s1323 PRE_first_tail_x15_r0_body.zl137 := PRE_first_tail_x15_r0_body.zimgE137
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl137 : PRE_first_tail_x15_r0_body.s1323.ctl = PRE_first_tail_x15_r0_body.kappa137.ctl PRE_first_tail_x15_r0_body.s1324.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack137 : PRE_first_tail_x15_r0_body.s1323.stack = PRE_first_tail_x15_r0_body.s1324.stack.map PRE_first_tail_x15_r0_body.kappa137.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs137 : PRE_first_tail_x15_r0_body.s1323.jobs = PRE_first_tail_x15_r0_body.s1324.jobs.map PRE_first_tail_x15_r0_body.kappa137.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores137 : PRE_first_tail_x15_r0_body.s1323.stores = PRE_first_tail_x15_r0_body.kappa137.stores PRE_first_tail_x15_r0_body.s1324.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots137 : checkRootsSupp PRE_first_tail_x15_r0_body.s1324 5911 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC137 : PRE_first_tail_x15_r0_body.S1322.tab.length + PRE_first_tail_x15_r0_body.cws137.length = 5911
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap137 : PRE_first_tail_x15_r0_body.kappa137 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1322.next 2782095 PRE_first_tail_x15_r0_body.S1322.tab.length PRE_first_tail_x15_r0_body.pl137 (PRE_first_tail_x15_r0_body.nr137.map NumV.ref) PRE_first_tail_x15_r0_body.kd137.big
  PRE_first_tail_x15_r0_body.kd137.region PRE_first_tail_x15_r0_body.kd137.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin137 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1324.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc137 : Conv.jcleanListB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1324 PRE_first_tail_x15_r0_body.cl137 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB137 : noBigRootsP (fun i => !Conv.oldBigB (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1324.trace PRE_first_tail_x15_r0_body.s1324 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm137 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 17992 = true
theorem PRE_first_tail_x15_r0_body.cjcl137 (h : Conv.JClean (⟨20892, 17992, 2782075, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1322) : Conv.JClean (⟨20892, 17992, 2782076, 5911⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1324 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle137)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap137 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd137 a ha)) PRE_first_tail_x15_r0_body.zjc137

end Host.Load.Run.Tpl
end

section -- st137/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st137.bodyLast from PRE_first_tail_x15_r0_body.st137.s1 to PRE_first_tail_x15_r0_body.st137.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st137.F PRE_first_tail_x15_r0_body.st137.s1).run PRE_first_tail_x15_r0_body.st137.S1 = some (PRE_first_tail_x15_r0_body.st137.s2, PRE_first_tail_x15_r0_body.st137.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st137.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st137.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st137.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st137.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st137/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st137.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st137.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st137.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st137.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st137.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st137.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st137.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st137.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st137.s0 PRE_first_tail_x15_r0_body.st137.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st137.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st137.s1 PRE_first_tail_x15_r0_body.st137.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st137/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st137.bodyK0F from PRE_first_tail_x15_r0_body.st137.s0 to PRE_first_tail_x15_r0_body.st137.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st137.F (PRE_first_tail_x15_r0_body.st137.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st137.ks 0).getD 0) PRE_first_tail_x15_r0_body.st137.s0 PRE_first_tail_x15_r0_body.st137.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st137.s1, PRE_first_tail_x15_r0_body.st137.S1)
theorem PRE_first_tail_x15_r0_body.st137.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st137.F (PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st137.ks 0).getD 0) PRE_first_tail_x15_r0_body.st137.s0 PRE_first_tail_x15_r0_body.st137.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st137.s1, PRE_first_tail_x15_r0_body.st137.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st137.bodyOkLN_ok PRE_first_tail_x15_r0_body.st137.bodyK0F
end Host.Load.Run.Tpl
end

section -- st137/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st137.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st137.F (PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st137.s0 PRE_first_tail_x15_r0_body.st137.S0 = some (PRE_first_tail_x15_r0_body.st137.s1, PRE_first_tail_x15_r0_body.st137.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st137.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st137.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st137.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st137.F (PRE_first_tail_x15_r0_body.st137.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st137.s0
  S0 := PRE_first_tail_x15_r0_body.st137.S0
  s1 := PRE_first_tail_x15_r0_body.st137.s1
  S1 := PRE_first_tail_x15_r0_body.st137.S1
  s2 := PRE_first_tail_x15_r0_body.st137.s2
  S2 := PRE_first_tail_x15_r0_body.st137.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st137.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st137.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st137.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st137.bodyHalt
  last := PRE_first_tail_x15_r0_body.st137.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st137.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 138 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1341` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa138` into the merged state
`PRE_first_tail_x15_r0_body.s1340`. -/

def PRE_first_tail_x15_r0_body.pl138 : List Nat := [2784663, 2783838, 2784669, 2784665, 2783840, 2784671]
def PRE_first_tail_x15_r0_body.nr138 : List Nat := [6014, 6013, 5989, 5997, 6002, 6007, 6012, 5986, 5987, 5988, 5995, 5996, 5984, 5991, 5992, 5993, 5994, 5990]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd138 : RData :=
  ⟨2783557, 2784706, Stage.setAll PTrie.nil [(2783551, 2784663), (2783552, 2783838), (2783553, 2784669), (2783554, 2784665), (2783555, 2783840), (2783556, 2784671)], Stage.setAll PTrie.nil [(20926, 20952), (20927, 20930), (20928, 20953)],
   20929, 20954, 18038, 18038, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(5984, .ref 6014), (5985, .ref 6013), (5986, .ref 5989), (5987, .ref 5997), (5988, .ref 6002), (5989, .ref 6007), (5990, .ref 6012), (5991, .ref 5986), (5992, .ref 5987), (5993, .ref 5988), (5994, .ref 5995), (5995, .ref 5996), (5996, .ref 5984), (5997, .ref 5991), (5998, .ref 5992), (5999, .ref 5993), (6000, .ref 5994), (6001, .ref 5990)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa138 : Map :=
  Conv.Map.compact 2783551 2784706 5984 PRE_first_tail_x15_r0_body.pl138 (PRE_first_tail_x15_r0_body.nr138.map NumV.ref) PRE_first_tail_x15_r0_body.kd138.big
    PRE_first_tail_x15_r0_body.kd138.region PRE_first_tail_x15_r0_body.kd138.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws138 : List Nat := [3334, 3335, 3336, 3337, 3338, 3339, 3340, 3341, 3342, 3343, 3344, 3345, 3346, 3347, 3348, 3349, 3350, 3351]
noncomputable def PRE_first_tail_x15_r0_body.crs138 : List SymE := PRE_first_tail_x15_r0_body.nr138.map fun r => (nth? PRE_first_tail_x15_r0_body.S1340.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta138 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws138 PRE_first_tail_x15_r0_body.crs138
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB138 : List Nat := [2665, 2672651, 2673467, 2782725, 2783270, 2783526]

kernel_rfl PRE_first_tail_x15_r0_body.ctab138 : PRE_first_tail_x15_r0_body.S1341.tab = PRE_first_tail_x15_r0_body.S1339.tab ++ PRE_first_tail_x15_r0_body.cws138.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace138 : PRE_first_tail_x15_r0_body.s1341.trace = PRE_first_tail_x15_r0_body.s1339.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext138 : PRE_first_tail_x15_r0_body.s1341.next = 2783557
kernel_rfl PRE_first_tail_x15_r0_body.ccounters138 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.nnext) = (20929, 18038)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1340.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa138.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.tokens.all (bSN 6002) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean138 : Conv.cleanListB 20929 131072 (fun r => Nat.ble 83716 r) PRE_first_tail_x15_r0_body.s1341
    (PRE_first_tail_x15_r0_body.wrB138 ++ (List.range 6).map (2783551 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs138 : bigsOutB 20929 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl138`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl138 : List Nat := [2665, 2672651, 2673467, 2782725, 2783270, 2783526, 2783551, 2783552, 2783553, 2783554, 2783555, 2783556]
def PRE_first_tail_x15_r0_body.clo138 : List Nat := [20906, 20919, 20925, 20926, 20927, 20928]
def PRE_first_tail_x15_r0_body.cln138 : List Nat := [18011, 18012, 18013, 18014, 18015, 18016, 18017, 18018, 18019, 18020, 18021, 18022, 18023, 18024, 18025, 18026, 18027, 18028, 18029, 18030, 18031, 18032, 18033, 18034, 18035, 18036, 18037]
def PRE_first_tail_x15_r0_body.cli138 : List Nat := [18011, 18012, 18013, 18014, 18015, 18016, 18017, 18018, 18019, 18020, 18021, 18022, 18023, 18024, 18025, 18026, 18027, 18028, 18029, 18030, 18031, 18032, 18033, 18034, 18035, 18036, 18037]
kernel_rfl PRE_first_tail_x15_r0_body.cheap138 : PRE_first_tail_x15_r0_body.s1341.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1339.heap (PRE_first_tail_x15_r0_body.cl138.filterMap fun a => (PRE_first_tail_x15_r0_body.s1341.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe138 : Nat.ble PRE_first_tail_x15_r0_body.s1339.next PRE_first_tail_x15_r0_body.s1341.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP138 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp138 : Conv.suppListB PRE_first_tail_x15_r0_body.s1341 6002 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound138 : Conv.boundListB PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst138 : Conv.sstListB 6002 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cli138 = true

end Host.Load.Run.Tpl
end

section -- SiteCl138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA138 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd138 : (PRE_first_tail_x15_r0_body.clo138 ++ PRE_first_tail_x15_r0_body.cln138 ++ PRE_first_tail_x15_r0_body.cli138).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle138 : Conv.Cnt.leB (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck138 : Conv.ncleanListB (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.cli138 = true
theorem PRE_first_tail_x15_r0_body.cncl138 (h : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) : Conv.NClean (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle138 PRE_first_tail_x15_r0_body.ckA138 PRE_first_tail_x15_r0_body.cobjsK138 PRE_first_tail_x15_r0_body.cnodesK138 PRE_first_tail_x15_r0_body.citemsK138 PRE_first_tail_x15_r0_body.cbd138 PRE_first_tail_x15_r0_body.cck138

end Host.Load.Run.Tpl
end

section -- SiteS138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 138 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc138 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P138 : LoadP := PRE_first_tail_x15_r0_body.Pc138.raise 18038
kernel_rfl PRE_first_tail_x15_r0_body.craise138 : Nat.ble PRE_first_tail_x15_r0_body.Pc138.N0 18038 = true
theorem PRE_first_tail_x15_r0_body.raised138 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc138 PRE_first_tail_x15_r0_body.P138 :=
  .inr ⟨18038, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise138, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_138 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_138 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1340.ffi)
def PRE_first_tail_x15_r0_body.khinv138 : PTrie Nat := Stage.setAll PTrie.nil [(20952, 20926), (20930, 20927), (20953, 20928)]
def PRE_first_tail_x15_r0_body.kninv138 : PTrie Nat := Stage.setAll PTrie.nil [(18011, 18011), (18012, 18012), (18013, 18013), (18014, 18014), (18015, 18015), (18016, 18016), (18017, 18017), (18018, 18018), (18019, 18019), (18020, 18020), (18021, 18021), (18022, 18022), (18023, 18023), (18024, 18024), (18025, 18025), (18026, 18026), (18027, 18027), (18028, 18028), (18029, 18029), (18030, 18030), (18031, 18031), (18032, 18032), (18033, 18033), (18034, 18034), (18035, 18035), (18036, 18036), (18037, 18037)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS138 : List Nat := [20906, 20919, 20925, 20926, 20927, 20928, 20929, 20930, 20931, 20932, 20933, 20934, 20935, 20936, 20937, 20938, 20939, 20940, 20941, 20942, 20943, 20944, 20945, 20946, 20947, 20948, 20949, 20950, 20951, 20952, 20953]
def PRE_first_tail_x15_r0_body.cnS138 : List Nat := List.range' 18011 27
def PRE_first_tail_x15_r0_body.ciS138 : List Nat := [] ++ List.range' 18011 27

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0138 : PRE_first_tail_x15_r0_body.kd138.nh0 = PRE_first_tail_x15_r0_body.cx0_138.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1138 : PRE_first_tail_x15_r0_body.kd138.nh1 = PRE_first_tail_x15_r0_body.cx1_138.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0138 : PRE_first_tail_x15_r0_body.kd138.nn0 = PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1138 : PRE_first_tail_x15_r0_body.kd138.nn1 = PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo138 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P138.lo && Nat.ble PRE_first_tail_x15_r0_body.P138.lo PRE_first_tail_x15_r0_body.cx0_138.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P138.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P138.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt138 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_138.mlx.next PRE_first_tail_x15_r0_body.cx1_138.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband138 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P138.NL && Nat.ble PRE_first_tail_x15_r0_body.P138.NL PRE_first_tail_x15_r0_body.P138.N0 && Nat.ble PRE_first_tail_x15_r0_body.P138.N0 PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow138 : PRE_first_tail_x15_r0_body.kd138.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren138 : checkRenG PRE_first_tail_x15_r0_body.kd138.hnd PRE_first_tail_x15_r0_body.khinv138 (phB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband138 : PRE_first_tail_x15_r0_body.kd138.checkBand PRE_first_tail_x15_r0_body.P138.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos138 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd138.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren138 : checkRenG PRE_first_tail_x15_r0_body.kd138.node PRE_first_tail_x15_r0_body.kninv138 (pnB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P138.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd138.nodeF j) PRE_first_tail_x15_r0_body.cx1_138.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a138 : PRE_first_tail_x15_r0_body.cx0_138.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b138 : PRE_first_tail_x15_r0_body.cx0_138.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.pending = PRE_first_tail_x15_r0_body.cx0_138.mlx.pending.map PRE_first_tail_x15_r0_body.kappa138.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.errh = PRE_first_tail_x15_r0_body.cx0_138.mlx.errh.map PRE_first_tail_x15_r0_body.kappa138.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.files = PRE_first_tail_x15_r0_body.cx0_138.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.arch = PRE_first_tail_x15_r0_body.cx0_138.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_138.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.wired = PRE_first_tail_x15_r0_body.cx0_138.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost138 : PRE_first_tail_x15_r0_body.cx1_138.host = PRE_first_tail_x15_r0_body.cx0_138.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd138`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0138 : PRE_first_tail_x15_r0_body.kd138.n0 = 2783557
kernel_rfl PRE_first_tail_x15_r0_body.ckn1138 : PRE_first_tail_x15_r0_body.kd138.n1 = 2784706
kernel_rfl PRE_first_tail_x15_r0_body.ckheap138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.heap).all (fun x => Nat.ble 2783551 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl138 : (List.range 6).all (fun j => decide (PRE_first_tail_x15_r0_body.kd138.heap.get (2783551 + j) = nth? PRE_first_tail_x15_r0_body.pl138 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja138 : Nat.ble 2783551 2783551 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn138 : Nat.ble 5984 5984 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD138 : Nat.ble 2783551 PRE_first_tail_x15_r0_body.kd138.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn138 : Nat.ble 20926 PRE_first_tail_x15_r0_body.kd138.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn138 : Nat.ble 18011 PRE_first_tail_x15_r0_body.kd138.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb138 : Nat.ble 20926 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.heap).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.hnd).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (Nat.ble (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix138 : Conv.FixOld (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa138 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn138) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb138) PRE_first_tail_x15_r0_body.fheap138 PRE_first_tail_x15_r0_body.fhnd138 PRE_first_tail_x15_r0_body.fnode138
kernel_rfl PRE_first_tail_x15_r0_body.fcxn138 : (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn138 : (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0138 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_138.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_138.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I138 : PRE_first_tail_x15_r0_body.cx1_138.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS138.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd138 : (PRE_first_tail_x15_r0_body.clo138 ++ PRE_first_tail_x15_r0_body.cln138 ++ PRE_first_tail_x15_r0_body.cli138 ++ PRE_first_tail_x15_r0_body.cwS138 ++ PRE_first_tail_x15_r0_body.cnS138 ++ PRE_first_tail_x15_r0_body.ciS138).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW138 : PRE_first_tail_x15_r0_body.cwS138.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo138.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI138 : PRE_first_tail_x15_r0_body.ciS138.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli138.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN138 : PRE_first_tail_x15_r0_body.cnS138.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF138 : PRE_first_tail_x15_r0_body.cln138.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh138 : PRE_first_tail_x15_r0_body.clo138.all (handleOK PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138.lo PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo138 : PRE_first_tail_x15_r0_body.clo138.map (fun h => PRE_first_tail_x15_r0_body.cx1_138.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa138.handle h)) = PRE_first_tail_x15_r0_body.clo138.map (fun h => (PRE_first_tail_x15_r0_body.cx0_138.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa138.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok138 : PRE_first_tail_x15_r0_body.clo138.all (objOK PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138.NL PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd138 : PRE_first_tail_x15_r0_body.cln138.all (nodeOKF PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.P138 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp138 : ((PRE_first_tail_x15_r0_body.cln138.filter (fullB PRE_first_tail_x15_r0_body.P138))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_138.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa138.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln138.filter (fullB PRE_first_tail_x15_r0_body.P138))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_138.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa138.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI138 : incrB PRE_first_tail_x15_r0_body.kd138.nodeF (List.range' 18011 27) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK138 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all (fun k => Nat.ble 18011 k && Nat.blt k 18038) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL138 : (PRE_first_tail_x15_r0_body.cln138.filter (Nat.ble PRE_first_tail_x15_r0_body.P138.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd138.nodeF i) && (Nat.blt i 18038 || Nat.ble PRE_first_tail_x15_r0_body.kd138.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord138 : (PRE_first_tail_x15_r0_body.cln138.filter (Nat.ble PRE_first_tail_x15_r0_body.P138.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd138.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd138.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd138.nodeF j) (PRE_first_tail_x15_r0_body.kd138.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow138 PRE_first_tail_x15_r0_body.cnn1138 PRE_first_tail_x15_r0_body.fnordI138 PRE_first_tail_x15_r0_body.fnordK138 PRE_first_tail_x15_r0_body.fnordL138
kernel_rfl PRE_first_tail_x15_r0_body.fi138 : PRE_first_tail_x15_r0_body.cli138.all (pnB PRE_first_tail_x15_r0_body.cx0_138.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii138 : PRE_first_tail_x15_r0_body.cli138.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_138.mlx.items.get (PRE_first_tail_x15_r0_body.kappa138.node k) = (PRE_first_tail_x15_r0_body.cx0_138.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa138.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.kd138 PRE_first_tail_x15_r0_body.khinv138 PRE_first_tail_x15_r0_body.kninv138 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.cx1_138.mlx (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo138 PRE_first_tail_x15_r0_body.cln138 PRE_first_tail_x15_r0_body.cli138 PRE_first_tail_x15_r0_body.cwS138 PRE_first_tail_x15_r0_body.cnS138 PRE_first_tail_x15_r0_body.ciS138 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0138, PRE_first_tail_x15_r0_body.cnh1138, PRE_first_tail_x15_r0_body.cnn0138, PRE_first_tail_x15_r0_body.cnn1138, PRE_first_tail_x15_r0_body.cplo138, PRE_first_tail_x15_r0_body.ccnt138, PRE_first_tail_x15_r0_body.cnband138, PRE_first_tail_x15_r0_body.chbelow138, PRE_first_tail_x15_r0_body.chren138, PRE_first_tail_x15_r0_body.cband138, PRE_first_tail_x15_r0_body.cnh1pos138, PRE_first_tail_x15_r0_body.cnren138, PRE_first_tail_x15_r0_body.cnlow138, PRE_first_tail_x15_r0_body.cabs0a138, PRE_first_tail_x15_r0_body.cabs0b138, PRE_first_tail_x15_r0_body.ctok1138, PRE_first_tail_x15_r0_body.cpend138, PRE_first_tail_x15_r0_body.cerrh138, PRE_first_tail_x15_r0_body.cfiles138, PRE_first_tail_x15_r0_body.carch138, PRE_first_tail_x15_r0_body.csizes138, PRE_first_tail_x15_r0_body.cwired138, PRE_first_tail_x15_r0_body.cfix138, clean, PRE_first_tail_x15_r0_body.fcxn138, PRE_first_tail_x15_r0_body.fcnn138, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0138, PRE_first_tail_x15_r0_body.fnk138, PRE_first_tail_x15_r0_body.ckA138, PRE_first_tail_x15_r0_body.cobjsK138, PRE_first_tail_x15_r0_body.cnodesK138, PRE_first_tail_x15_r0_body.citemsK138, PRE_first_tail_x15_r0_body.f1A138, PRE_first_tail_x15_r0_body.f1O138, PRE_first_tail_x15_r0_body.f1N138, PRE_first_tail_x15_r0_body.f1I138, PRE_first_tail_x15_r0_body.fbd138, PRE_first_tail_x15_r0_body.fincW138, PRE_first_tail_x15_r0_body.fincI138, PRE_first_tail_x15_r0_body.fincN138, PRE_first_tail_x15_r0_body.flnF138, PRE_first_tail_x15_r0_body.fh138, PRE_first_tail_x15_r0_body.fo138, PRE_first_tail_x15_r0_body.fok138, PRE_first_tail_x15_r0_body.fnd138, PRE_first_tail_x15_r0_body.fp138, PRE_first_tail_x15_r0_body.fnord138, PRE_first_tail_x15_r0_body.fi138, PRE_first_tail_x15_r0_body.fii138⟩
theorem PRE_first_tail_x15_r0_body.cnshift138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx) : NShift PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.cx0_138 PRE_first_tail_x15_r0_body.cx1_138 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost138 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0138 PRE_first_tail_x15_r0_body.ckn1138 PRE_first_tail_x15_r0_body.ckheap138 PRE_first_tail_x15_r0_body.ckpl138)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1339.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1339.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1339.ffi) = some PRE_first_tail_x15_r0_body.fxC_138
kernel_rfl PRE_first_tail_x15_r0_body.okrC_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1339.ffi) = some PRE_first_tail_x15_r0_body.krC_138
noncomputable def PRE_first_tail_x15_r0_body.fx0_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1341.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1341.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1341.ffi) = some PRE_first_tail_x15_r0_body.fx0_138
kernel_rfl PRE_first_tail_x15_r0_body.okr0_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1341.ffi) = some PRE_first_tail_x15_r0_body.kr0_138
noncomputable def PRE_first_tail_x15_r0_body.fx1_138 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1340.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_138 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1340.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_138 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1340.ffi) = some PRE_first_tail_x15_r0_body.fx1_138
kernel_rfl PRE_first_tail_x15_r0_body.okr1_138 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1340.ffi) = some PRE_first_tail_x15_r0_body.kr1_138
kernel_rfl PRE_first_tail_x15_r0_body.ff0138 : PRE_first_tail_x15_r0_body.fx0_138 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_138 (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_138.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1138 : PRE_first_tail_x15_r0_body.fx1_138 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_138 (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_138.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck138 : freedLB PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.fx0_138 PRE_first_tail_x15_r0_body.fx1_138 PRE_first_tail_x15_r0_body.clo138 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0138 : PRE_first_tail_x15_r0_body.kr0_138.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.flags (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_138.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0138 : PRE_first_tail_x15_r0_body.kr0_138.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.targs (PRE_first_tail_x15_r0_body.clo138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_138.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1138 : PRE_first_tail_x15_r0_body.kr1_138.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.flags (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_138.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1138 : PRE_first_tail_x15_r0_body.kr1_138.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_138.targs (PRE_first_tail_x15_r0_body.cwS138.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_138.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck138 : krecLB PRE_first_tail_x15_r0_body.kappa138 6002 PRE_first_tail_x15_r0_body.cx0_138.mlx PRE_first_tail_x15_r0_body.kr0_138 PRE_first_tail_x15_r0_body.kr1_138 PRE_first_tail_x15_r0_body.clo138 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn138 : Nat.ble 5984 6002 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge138 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1340.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1341.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR138 : pendRegB PRE_first_tail_x15_r0_body.kappa138 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe138 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1341.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1340.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift138 (clean : Conv.NClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P138.NL) (cl : SSt (· < 6002) PRE_first_tail_x15_r0_body.cx0_138.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_138.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_138.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_138.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1339.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_138.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P138 6002 PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.s1341.ffi PRE_first_tail_x15_r0_body.s1340.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift138 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue138, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp138 t ht),
    PRE_first_tail_x15_r0_body.cbridge138,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1341.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1340.ffi) (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_138 PRE_first_tail_x15_r0_body.ofx1_138 hobjC PRE_first_tail_x15_r0_body.ff0138 PRE_first_tail_x15_r0_body.ff1138 PRE_first_tail_x15_r0_body.ffck138,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1341.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1340.ffi) (PRE_first_tail_x15_r0_body.cfoot138 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_138 PRE_first_tail_x15_r0_body.okr1_138 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn138) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0138 PRE_first_tail_x15_r0_body.fkt0138 PRE_first_tail_x15_r0_body.fkf1138 PRE_first_tail_x15_r0_body.fkt1138 PRE_first_tail_x15_r0_body.fkck138,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0138 PRE_first_tail_x15_r0_body.cnh1138 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe138) PRE_first_tail_x15_r0_body.cpendR138⟩

end Host.Load.Run.Tpl
end

section -- st138/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st138 0
host_stream_state PRE_first_tail_x15_r0_body.st138 1
host_stream_state PRE_first_tail_x15_r0_body.st138 2
host_stream_state PRE_first_tail_x15_r0_body.st138 3
host_stream_state PRE_first_tail_x15_r0_body.st138 4
host_stream_state PRE_first_tail_x15_r0_body.st138 5
end Host.Load.Run.Tpl
end

section -- Site138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 138 of chain `PRE_first_tail_x15_r0_body`: `ssmW__g138__g139` (`recurWindow`), the call state `PRE_first_tail_x15_r0_body.s1339`, the merged state `PRE_first_tail_x15_r0_body.s1340`,
the site template `PRE_first_tail_x15_r0_body.st138` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1341`: the merge.
The footprint's facts are in `SiteF138`, the compaction's in `SiteC138`, `SiteK138`, `SiteNa138`, `SiteNb138`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso138 : PRE_first_tail_x15_r0_body.st138.s0 = { PRE_first_tail_x15_r0_body.s1339 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs138 : List Frame := PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_138 : PRE_first_tail_x15_r0_body.S1339.tab.length = 5984
kernel_rfl PRE_first_tail_x15_r0_body.tab0_138 : PRE_first_tail_x15_r0_body.st138.S0.tab = PRE_first_tail_x15_r0_body.S1339.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws138 : List Nat := [3303, 3304, 3305, 3306, 3307, 3308, 3309, 3310, 3311, 3312, 3313, 3314, 3315, 3316, 3317, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3326, 3327, 3328, 3329, 3330, 3331, 3332, 3333]
kernel_rfl PRE_first_tail_x15_r0_body.fresh138 : (PRE_first_tail_x15_r0_body.S1339.tab.all fun e => PRE_first_tail_x15_r0_body.ws138.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1339.oracle.all fun q => PRE_first_tail_x15_r0_body.ws138.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab138 : PRE_first_tail_x15_r0_body.S1340.tab = PRE_first_tail_x15_r0_body.S1339.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws138
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen138 : PRE_first_tail_x15_r0_body.st138.S5.tab.length - PRE_first_tail_x15_r0_body.st138.S0.tab.length = 31

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged138`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap138 : PRE_first_tail_x15_r0_body.s1340.heap = PRE_first_tail_x15_r0_body.st138.s5.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext138 : PRE_first_tail_x15_r0_body.s1340.next = PRE_first_tail_x15_r0_body.st138.s5.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl138 : PRE_first_tail_x15_r0_body.s1340.ctl = PRE_first_tail_x15_r0_body.st138.s5.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack138 : PRE_first_tail_x15_r0_body.s1340.stack = PRE_first_tail_x15_r0_body.st138.s5.stack ++ PRE_first_tail_x15_r0_body.s1339.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs138 : PRE_first_tail_x15_r0_body.s1340.jobs = PRE_first_tail_x15_r0_body.st138.s5.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi138 : PRE_first_tail_x15_r0_body.s1340.ffi = PRE_first_tail_x15_r0_body.st138.s5.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace138 : PRE_first_tail_x15_r0_body.s1340.trace = PRE_first_tail_x15_r0_body.st138.s5.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores138 : PRE_first_tail_x15_r0_body.s1340.stores = PRE_first_tail_x15_r0_body.st138.s5.stores

end Host.Load.Run.Tpl
end

section -- SiteD138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 138 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived138 : PRE_first_tail_x15_r0_body.nr138.map (fun r => nth? PRE_first_tail_x15_r0_body.st138.S5.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))))),
   some (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.un .int32 (SymE.un .int32 (SymE.var 10))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.un .int32 (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))),
   some (SymE.bin .sub (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0)))) (SymE.lit (F64.zero false))),
   some (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 3 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 3 (0))))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo138 : PRE_first_tail_x15_r0_body.nr138.all (Nat.ble 5984) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj138 : PRE_first_tail_x15_r0_body.cws138.all (fun c => !PRE_first_tail_x15_r0_body.ws138.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ138 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws138 PRE_first_tail_x15_r0_body.crs138 PRE_first_tail_x15_r0_body.ws138

end Host.Load.Run.Tpl
end

section -- st138/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st138`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st138.wrR : List (Nat × Nat) := [(2672651, 2672652), (2782725, 2782726), (2783270, 2783271), (2783526, 2783527)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st138.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st138.s5.heap PRE_first_tail_x15_r0_body.st138.wrR ++ freshOf PRE_first_tail_x15_r0_body.st138.s5.heap PRE_first_tail_x15_r0_body.st138.s0.next PRE_first_tail_x15_r0_body.st138.s5.next
noncomputable def PRE_first_tail_x15_r0_body.st138.wr : List Nat := PRE_first_tail_x15_r0_body.st138.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st138.heapFoot : PRE_first_tail_x15_r0_body.st138.s5.heap = setAll PRE_first_tail_x15_r0_body.st138.s0.heap PRE_first_tail_x15_r0_body.st138.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st138.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st138.s0.next PRE_first_tail_x15_r0_body.st138.s5.next = true
theorem PRE_first_tail_x15_r0_body.st138.grows : PRE_first_tail_x15_r0_body.st138.s0.next ≤ PRE_first_tail_x15_r0_body.st138.s5.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st138.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st138.wh : List Nat := [20906, 20919, 20925, 20926, 20927, 20928, 20929, 20930, 20931, 20932, 20933, 20934, 20935, 20936, 20937, 20938, 20939, 20940, 20941, 20942, 20943, 20944, 20945, 20946, 20947, 20948, 20949, 20950, 20951, 20952, 20953]
def PRE_first_tail_x15_r0_body.st138.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st138.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st138.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st138.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st138.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st138.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st138.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st138.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st138.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st138.s5.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 138 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB138 : nodupT PRE_first_tail_x15_r0_body.st138.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup138 : PRE_first_tail_x15_r0_body.st138.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB138).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB138 : PRE_first_tail_x15_r0_body.st138.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound138 : ∀ b ∈ PRE_first_tail_x15_r0_body.st138.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB138 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr138 := PRE_first_tail_x15_r0_body.st138.s5.trace.take 120
kernel_rfl PRE_first_tail_x15_r0_body.traceEq138 : PRE_first_tail_x15_r0_body.st138.s5.trace = PRE_first_tail_x15_r0_body.trFr138 ++ PRE_first_tail_x15_r0_body.st138.s0.trace
theorem PRE_first_tail_x15_r0_body.trace138 : ∃ fr, PRE_first_tail_x15_r0_body.st138.s5.trace = fr ++ PRE_first_tail_x15_r0_body.st138.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq138⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide138 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB138 : (PRE_first_tail_x15_r0_body.wide138.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st138.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix138 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide138, WFix Map.id (Present PRE_first_tail_x15_r0_body.st138.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB138 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 138 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1340`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO138 : PRE_first_tail_x15_r0_body.st138.S0.oracle = PRE_first_tail_x15_r0_body.st138.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B138 : PRE_first_tail_x15_r0_body.st138.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st138.s0.next || (PRE_first_tail_x15_r0_body.st138.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot138 : Conv.StageFoot PRE_first_tail_x15_r0_body.st138.wr PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.s5 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st138.heapFoot PRE_first_tail_x15_r0_body.wrNodup138 PRE_first_tail_x15_r0_body.wrBound138 PRE_first_tail_x15_r0_body.wr0B138 PRE_first_tail_x15_r0_body.st138.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged138 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st138.F.S → PRE_first_tail_x15_r0_body.st138.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st138.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st138.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs138 PRE_first_tail_x15_r0_body.st138.wr PRE_first_tail_x15_r0_body.s1339 PRE_first_tail_x15_r0_body.st138.s5 PRE_first_tail_x15_r0_body.st138.s0
      PRE_first_tail_x15_r0_body.st138.s5.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st138.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1340 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso138 PRE_first_tail_x15_r0_body.stFoot138 PRE_first_tail_x15_r0_body.wrNodup138 PRE_first_tail_x15_r0_body.wrBound138 PRE_first_tail_x15_r0_body.trace138 PRE_first_tail_x15_r0_body.mheap138
    PRE_first_tail_x15_r0_body.mnext138 PRE_first_tail_x15_r0_body.mctl138 PRE_first_tail_x15_r0_body.mstack138 PRE_first_tail_x15_r0_body.mjobs138 PRE_first_tail_x15_r0_body.mffi138 PRE_first_tail_x15_r0_body.mtrace138 PRE_first_tail_x15_r0_body.mstores138 h

def PRE_first_tail_x15_r0_body.arrEl138_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE138_2665 : arrOf PRE_first_tail_x15_r0_body.s1340 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl138_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA138_2665 : isArrB PRE_first_tail_x15_r0_body.s1340 2665 = true
theorem PRE_first_tail_x15_r0_body.arr138_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1340.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl138_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE138_2665 PRE_first_tail_x15_r0_body.arrA138_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN138_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl138_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR138_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl138_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN138_2665

def PRE_first_tail_x15_r0_body.arrEl138_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE138_2673467 : arrOf PRE_first_tail_x15_r0_body.s1340 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl138_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA138_2673467 : isArrB PRE_first_tail_x15_r0_body.s1340 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr138_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1340.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl138_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE138_2673467 PRE_first_tail_x15_r0_body.arrA138_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN138_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl138_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR138_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl138_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN138_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k138 : isArrB PRE_first_tail_x15_r0_body.s1340 4910 = false
theorem PRE_first_tail_x15_r0_body.keep138 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1340 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k138 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr138_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl138_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ138
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 138 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1339`, the merged
state `PRE_first_tail_x15_r0_body.s1340`, the canonical state `PRE_first_tail_x15_r0_body.s1341`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl138 : PRE_first_tail_x15_r0_body.pl138.all (Nat.ble PRE_first_tail_x15_r0_body.s1339.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd138 : nodupT PRE_first_tail_x15_r0_body.pl138 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1138 : Nat.ble PRE_first_tail_x15_r0_body.s1339.next 2784706 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst138 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1339.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn138 : PRE_first_tail_x15_r0_body.s1341.next = PRE_first_tail_x15_r0_body.s1339.next + PRE_first_tail_x15_r0_body.pl138.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn138 : PRE_first_tail_x15_r0_body.s1340.next = 2784706
kernel_rfl PRE_first_tail_x15_r0_body.zgrow138 : Nat.ble PRE_first_tail_x15_r0_body.s1341.next PRE_first_tail_x15_r0_body.s1340.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh138 : PRE_first_tail_x15_r0_body.S1339.tab.all (fun e => PRE_first_tail_x15_r0_body.cws138.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd138 : nodupT PRE_first_tail_x15_r0_body.cws138 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi138 : PRE_first_tail_x15_r0_body.nr138.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1340.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt138 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1339.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg138_2665 : PRE_first_tail_x15_r0_body.s1341.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1341 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk138_2665 : (objOf PRE_first_tail_x15_r0_body.s1341 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm138_2665 : PRE_first_tail_x15_r0_body.s1340.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa138.obj (objOf PRE_first_tail_x15_r0_body.s1341 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1340 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg138_2673467 : PRE_first_tail_x15_r0_body.s1341.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1341 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk138_2673467 : (objOf PRE_first_tail_x15_r0_body.s1341 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm138_2673467 : PRE_first_tail_x15_r0_body.s1340.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa138.obj (objOf PRE_first_tail_x15_r0_body.s1341 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1340 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw138_4910 : (PRE_first_tail_x15_r0_body.s1341.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw138_2673472 : (PRE_first_tail_x15_r0_body.s1341.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw138_2673473 : (PRE_first_tail_x15_r0_body.s1341.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd138 : PRE_first_tail_x15_r0_body.cl138.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr138 : PRE_first_tail_x15_r0_body.st138.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1339.next || PRE_first_tail_x15_r0_body.cl138.contains b) = true
def PRE_first_tail_x15_r0_body.zl138 : List Nat := PRE_first_tail_x15_r0_body.cl138.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE138 : PRE_first_tail_x15_r0_body.zl138.map (fun a => PRE_first_tail_x15_r0_body.s1340.heap.get (PRE_first_tail_x15_r0_body.kappa138.a a)) = PRE_first_tail_x15_r0_body.zl138.map (fun a => (PRE_first_tail_x15_r0_body.s1341.heap.get a).map PRE_first_tail_x15_r0_body.kappa138.hobj)
theorem PRE_first_tail_x15_r0_body.zimg138 : HeapImg PRE_first_tail_x15_r0_body.kappa138 PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.s1340 PRE_first_tail_x15_r0_body.zl138 := PRE_first_tail_x15_r0_body.zimgE138
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl138 : PRE_first_tail_x15_r0_body.s1340.ctl = PRE_first_tail_x15_r0_body.kappa138.ctl PRE_first_tail_x15_r0_body.s1341.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack138 : PRE_first_tail_x15_r0_body.s1340.stack = PRE_first_tail_x15_r0_body.s1341.stack.map PRE_first_tail_x15_r0_body.kappa138.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs138 : PRE_first_tail_x15_r0_body.s1340.jobs = PRE_first_tail_x15_r0_body.s1341.jobs.map PRE_first_tail_x15_r0_body.kappa138.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores138 : PRE_first_tail_x15_r0_body.s1340.stores = PRE_first_tail_x15_r0_body.kappa138.stores PRE_first_tail_x15_r0_body.s1341.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots138 : checkRootsSupp PRE_first_tail_x15_r0_body.s1341 6002 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC138 : PRE_first_tail_x15_r0_body.S1339.tab.length + PRE_first_tail_x15_r0_body.cws138.length = 6002
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap138 : PRE_first_tail_x15_r0_body.kappa138 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1339.next 2784706 PRE_first_tail_x15_r0_body.S1339.tab.length PRE_first_tail_x15_r0_body.pl138 (PRE_first_tail_x15_r0_body.nr138.map NumV.ref) PRE_first_tail_x15_r0_body.kd138.big
  PRE_first_tail_x15_r0_body.kd138.region PRE_first_tail_x15_r0_body.kd138.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin138 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1341.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc138 : Conv.jcleanListB (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.cl138 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB138 : noBigRootsP (fun i => !Conv.oldBigB (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1341.trace PRE_first_tail_x15_r0_body.s1341 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm138 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18011 = true
theorem PRE_first_tail_x15_r0_body.cjcl138 (h : Conv.JClean (⟨20926, 18011, 2783551, 5984⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1339) : Conv.JClean (⟨20929, 18038, 2783557, 6002⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1341 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle138)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap138 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd138 a ha)) PRE_first_tail_x15_r0_body.zjc138

end Host.Load.Run.Tpl
end

section -- st138/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st138.bodyLast from PRE_first_tail_x15_r0_body.st138.s4 to PRE_first_tail_x15_r0_body.st138.s5 :
  interpS (step PRE_first_tail_x15_r0_body.st138.F PRE_first_tail_x15_r0_body.st138.s4).run PRE_first_tail_x15_r0_body.st138.S4 = some (PRE_first_tail_x15_r0_body.st138.s5, PRE_first_tail_x15_r0_body.st138.S5)
kernel_rfl PRE_first_tail_x15_r0_body.st138.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st138.s4.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st138.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st138.s5.stack = true

end Host.Load.Run.Tpl
end

section -- st138/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st138.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st138.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st138.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st138.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st138.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st138.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st138.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st138.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st138.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st138.s4 PRE_first_tail_x15_r0_body.st138.S4) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st138/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st138.bodyK0F from PRE_first_tail_x15_r0_body.st138.s0 to PRE_first_tail_x15_r0_body.st138.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 0).getD 0) PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s1, PRE_first_tail_x15_r0_body.st138.S1)
theorem PRE_first_tail_x15_r0_body.st138.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 0).getD 0) PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s1, PRE_first_tail_x15_r0_body.st138.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st138.bodyOkLN_ok PRE_first_tail_x15_r0_body.st138.bodyK0F
end Host.Load.Run.Tpl
end

section -- st138/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st138.bodyK1F from PRE_first_tail_x15_r0_body.st138.s1 to PRE_first_tail_x15_r0_body.st138.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 1).getD 0) PRE_first_tail_x15_r0_body.st138.s1 PRE_first_tail_x15_r0_body.st138.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s2, PRE_first_tail_x15_r0_body.st138.S2)
theorem PRE_first_tail_x15_r0_body.st138.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 1).getD 0) PRE_first_tail_x15_r0_body.st138.s1 PRE_first_tail_x15_r0_body.st138.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s2, PRE_first_tail_x15_r0_body.st138.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st138.bodyOkLN_ok PRE_first_tail_x15_r0_body.st138.bodyK1F
end Host.Load.Run.Tpl
end

section -- st138/TypedK2
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st138.bodyK2F from PRE_first_tail_x15_r0_body.st138.s2 to PRE_first_tail_x15_r0_body.st138.s3 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 2).getD 0) PRE_first_tail_x15_r0_body.st138.s2 PRE_first_tail_x15_r0_body.st138.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s3, PRE_first_tail_x15_r0_body.st138.S3)
theorem PRE_first_tail_x15_r0_body.st138.bodyK2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 2).getD 0) PRE_first_tail_x15_r0_body.st138.s2 PRE_first_tail_x15_r0_body.st138.S2) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s3, PRE_first_tail_x15_r0_body.st138.S3) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st138.bodyOkLN_ok PRE_first_tail_x15_r0_body.st138.bodyK2F
end Host.Load.Run.Tpl
end

section -- st138/TypedK3
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st138.bodyK3F from PRE_first_tail_x15_r0_body.st138.s3 to PRE_first_tail_x15_r0_body.st138.s4 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 3).getD 0) PRE_first_tail_x15_r0_body.st138.s3 PRE_first_tail_x15_r0_body.st138.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s4, PRE_first_tail_x15_r0_body.st138.S4)
theorem PRE_first_tail_x15_r0_body.st138.bodyK3 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st138.ks 3).getD 0) PRE_first_tail_x15_r0_body.st138.s3 PRE_first_tail_x15_r0_body.st138.S3) = fun _ _ => some (PRE_first_tail_x15_r0_body.st138.s4, PRE_first_tail_x15_r0_body.st138.S4) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st138.bodyOkLN_ok PRE_first_tail_x15_r0_body.st138.bodyK3F
end Host.Load.Run.Tpl
end

section -- st138/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st138.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows) 11334 PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.S0 = some (PRE_first_tail_x15_r0_body.st138.s4, PRE_first_tail_x15_r0_body.st138.S4) :=
  runOk_trans PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows) ((((nth? PRE_first_tail_x15_r0_body.st138.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st138.ks 1).getD 0)) + ((nth? PRE_first_tail_x15_r0_body.st138.ks 2).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st138.ks 3).getD 0) PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.s3 PRE_first_tail_x15_r0_body.st138.s4 PRE_first_tail_x15_r0_body.st138.S0 PRE_first_tail_x15_r0_body.st138.S3 PRE_first_tail_x15_r0_body.st138.S4 (runOk_trans PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows) (((nth? PRE_first_tail_x15_r0_body.st138.ks 0).getD 0) + ((nth? PRE_first_tail_x15_r0_body.st138.ks 1).getD 0)) ((nth? PRE_first_tail_x15_r0_body.st138.ks 2).getD 0) PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.s2 PRE_first_tail_x15_r0_body.st138.s3 PRE_first_tail_x15_r0_body.st138.S0 PRE_first_tail_x15_r0_body.st138.S2 PRE_first_tail_x15_r0_body.st138.S3 (runOk_trans PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st138.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st138.ks 1).getD 0) PRE_first_tail_x15_r0_body.st138.s0 PRE_first_tail_x15_r0_body.st138.s1 PRE_first_tail_x15_r0_body.st138.s2 PRE_first_tail_x15_r0_body.st138.S0 PRE_first_tail_x15_r0_body.st138.S1 PRE_first_tail_x15_r0_body.st138.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyK1 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyK2 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyK3 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st138.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st138.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st138.F (PRE_first_tail_x15_r0_body.st138.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st138.s0
  S0 := PRE_first_tail_x15_r0_body.st138.S0
  s1 := PRE_first_tail_x15_r0_body.st138.s4
  S1 := PRE_first_tail_x15_r0_body.st138.S4
  s2 := PRE_first_tail_x15_r0_body.st138.s5
  S2 := PRE_first_tail_x15_r0_body.st138.S5
  n := 11334
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st138.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st138.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st138.bodyHalt
  last := PRE_first_tail_x15_r0_body.st138.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st138.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 139 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1349` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa139` into the merged state
`PRE_first_tail_x15_r0_body.s1348`. -/

def PRE_first_tail_x15_r0_body.pl139 : List Nat := []
def PRE_first_tail_x15_r0_body.nr139 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd139 : RData :=
  ⟨2784047, 2784049, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   20942, 20942, 18051, 18051, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa139 : Map :=
  Conv.Map.compact 2784047 2784049 6023 PRE_first_tail_x15_r0_body.pl139 (PRE_first_tail_x15_r0_body.nr139.map NumV.ref) PRE_first_tail_x15_r0_body.kd139.big
    PRE_first_tail_x15_r0_body.kd139.region PRE_first_tail_x15_r0_body.kd139.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws139 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs139 : List SymE := PRE_first_tail_x15_r0_body.nr139.map fun r => (nth? PRE_first_tail_x15_r0_body.S1348.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta139 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws139 PRE_first_tail_x15_r0_body.crs139
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB139 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab139 : PRE_first_tail_x15_r0_body.S1349.tab = PRE_first_tail_x15_r0_body.S1347.tab ++ PRE_first_tail_x15_r0_body.cws139.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace139 : PRE_first_tail_x15_r0_body.s1349.trace = PRE_first_tail_x15_r0_body.s1347.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext139 : PRE_first_tail_x15_r0_body.s1349.next = 2784047
kernel_rfl PRE_first_tail_x15_r0_body.ccounters139 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nnext) = (20942, 18051)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa139.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.tokens.all (bSN 6023) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean139 : Conv.cleanListB 20942 131072 (fun r => Nat.ble 83768 r) PRE_first_tail_x15_r0_body.s1349
    (PRE_first_tail_x15_r0_body.wrB139 ++ (List.range 0).map (2784047 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs139 : bigsOutB 20942 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl139`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl139 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo139 : List Nat := []
def PRE_first_tail_x15_r0_body.cln139 : List Nat := []
def PRE_first_tail_x15_r0_body.cli139 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap139 : PRE_first_tail_x15_r0_body.s1349.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1347.heap (PRE_first_tail_x15_r0_body.cl139.filterMap fun a => (PRE_first_tail_x15_r0_body.s1349.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe139 : Nat.ble PRE_first_tail_x15_r0_body.s1347.next PRE_first_tail_x15_r0_body.s1349.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP139 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp139 : Conv.suppListB PRE_first_tail_x15_r0_body.s1349 6023 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound139 : Conv.boundListB PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst139 : Conv.sstListB 6023 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cli139 = true

end Host.Load.Run.Tpl
end

section -- SiteCl139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA139 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd139 : (PRE_first_tail_x15_r0_body.clo139 ++ PRE_first_tail_x15_r0_body.cln139 ++ PRE_first_tail_x15_r0_body.cli139).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle139 : Conv.Cnt.leB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck139 : Conv.ncleanListB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.cli139 = true
theorem PRE_first_tail_x15_r0_body.cncl139 (h : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle139 PRE_first_tail_x15_r0_body.ckA139 PRE_first_tail_x15_r0_body.cobjsK139 PRE_first_tail_x15_r0_body.cnodesK139 PRE_first_tail_x15_r0_body.citemsK139 PRE_first_tail_x15_r0_body.cbd139 PRE_first_tail_x15_r0_body.cck139

end Host.Load.Run.Tpl
end

section -- SiteS139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 139 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc139 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P139 : LoadP := PRE_first_tail_x15_r0_body.Pc139.raise 18051
kernel_rfl PRE_first_tail_x15_r0_body.craise139 : Nat.ble PRE_first_tail_x15_r0_body.Pc139.N0 18051 = true
theorem PRE_first_tail_x15_r0_body.raised139 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc139 PRE_first_tail_x15_r0_body.P139 :=
  .inr ⟨18051, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise139, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_139 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_139 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi)
def PRE_first_tail_x15_r0_body.khinv139 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv139 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS139 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS139 : List Nat := List.range' 18051 0
def PRE_first_tail_x15_r0_body.ciS139 : List Nat := [] ++ List.range' 18051 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0139 : PRE_first_tail_x15_r0_body.kd139.nh0 = PRE_first_tail_x15_r0_body.cx0_139.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1139 : PRE_first_tail_x15_r0_body.kd139.nh1 = PRE_first_tail_x15_r0_body.cx1_139.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0139 : PRE_first_tail_x15_r0_body.kd139.nn0 = PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1139 : PRE_first_tail_x15_r0_body.kd139.nn1 = PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo139 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P139.lo && Nat.ble PRE_first_tail_x15_r0_body.P139.lo PRE_first_tail_x15_r0_body.cx0_139.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P139.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P139.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt139 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_139.mlx.next PRE_first_tail_x15_r0_body.cx1_139.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband139 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P139.NL && Nat.ble PRE_first_tail_x15_r0_body.P139.NL PRE_first_tail_x15_r0_body.P139.N0 && Nat.ble PRE_first_tail_x15_r0_body.P139.N0 PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow139 : PRE_first_tail_x15_r0_body.kd139.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren139 : checkRenG PRE_first_tail_x15_r0_body.kd139.hnd PRE_first_tail_x15_r0_body.khinv139 (phB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband139 : PRE_first_tail_x15_r0_body.kd139.checkBand PRE_first_tail_x15_r0_body.P139.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos139 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd139.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren139 : checkRenG PRE_first_tail_x15_r0_body.kd139.node PRE_first_tail_x15_r0_body.kninv139 (pnB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P139.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd139.nodeF j) PRE_first_tail_x15_r0_body.cx1_139.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a139 : PRE_first_tail_x15_r0_body.cx0_139.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b139 : PRE_first_tail_x15_r0_body.cx0_139.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.pending = PRE_first_tail_x15_r0_body.cx0_139.mlx.pending.map PRE_first_tail_x15_r0_body.kappa139.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.errh = PRE_first_tail_x15_r0_body.cx0_139.mlx.errh.map PRE_first_tail_x15_r0_body.kappa139.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.files = PRE_first_tail_x15_r0_body.cx0_139.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.arch = PRE_first_tail_x15_r0_body.cx0_139.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_139.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.wired = PRE_first_tail_x15_r0_body.cx0_139.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost139 : PRE_first_tail_x15_r0_body.cx1_139.host = PRE_first_tail_x15_r0_body.cx0_139.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd139`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0139 : PRE_first_tail_x15_r0_body.kd139.n0 = 2784047
kernel_rfl PRE_first_tail_x15_r0_body.ckn1139 : PRE_first_tail_x15_r0_body.kd139.n1 = 2784049
kernel_rfl PRE_first_tail_x15_r0_body.ckheap139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.heap).all (fun x => Nat.ble 2784047 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl139 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd139.heap.get (2784047 + j) = nth? PRE_first_tail_x15_r0_body.pl139 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja139 : Nat.ble 2784047 2784047 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn139 : Nat.ble 6023 6023 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD139 : Nat.ble 2784047 PRE_first_tail_x15_r0_body.kd139.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn139 : Nat.ble 20942 PRE_first_tail_x15_r0_body.kd139.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn139 : Nat.ble 18051 PRE_first_tail_x15_r0_body.kd139.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb139 : Nat.ble 20942 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.heap).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.hnd).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (Nat.ble (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix139 : Conv.FixOld (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa139 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn139) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb139) PRE_first_tail_x15_r0_body.fheap139 PRE_first_tail_x15_r0_body.fhnd139 PRE_first_tail_x15_r0_body.fnode139
kernel_rfl PRE_first_tail_x15_r0_body.fcxn139 : (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn139 : (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0139 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_139.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_139.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I139 : PRE_first_tail_x15_r0_body.cx1_139.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS139.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd139 : (PRE_first_tail_x15_r0_body.clo139 ++ PRE_first_tail_x15_r0_body.cln139 ++ PRE_first_tail_x15_r0_body.cli139 ++ PRE_first_tail_x15_r0_body.cwS139 ++ PRE_first_tail_x15_r0_body.cnS139 ++ PRE_first_tail_x15_r0_body.ciS139).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW139 : PRE_first_tail_x15_r0_body.cwS139.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo139.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI139 : PRE_first_tail_x15_r0_body.ciS139.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli139.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN139 : PRE_first_tail_x15_r0_body.cnS139.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF139 : PRE_first_tail_x15_r0_body.cln139.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh139 : PRE_first_tail_x15_r0_body.clo139.all (handleOK PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139.lo PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo139 : PRE_first_tail_x15_r0_body.clo139.map (fun h => PRE_first_tail_x15_r0_body.cx1_139.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa139.handle h)) = PRE_first_tail_x15_r0_body.clo139.map (fun h => (PRE_first_tail_x15_r0_body.cx0_139.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa139.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok139 : PRE_first_tail_x15_r0_body.clo139.all (objOK PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139.NL PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd139 : PRE_first_tail_x15_r0_body.cln139.all (nodeOKF PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.P139 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp139 : ((PRE_first_tail_x15_r0_body.cln139.filter (fullB PRE_first_tail_x15_r0_body.P139))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_139.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa139.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln139.filter (fullB PRE_first_tail_x15_r0_body.P139))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_139.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa139.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI139 : incrB PRE_first_tail_x15_r0_body.kd139.nodeF (List.range' 18051 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK139 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all (fun k => Nat.ble 18051 k && Nat.blt k 18051) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL139 : (PRE_first_tail_x15_r0_body.cln139.filter (Nat.ble PRE_first_tail_x15_r0_body.P139.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd139.nodeF i) && (Nat.blt i 18051 || Nat.ble PRE_first_tail_x15_r0_body.kd139.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord139 : (PRE_first_tail_x15_r0_body.cln139.filter (Nat.ble PRE_first_tail_x15_r0_body.P139.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd139.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd139.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd139.nodeF j) (PRE_first_tail_x15_r0_body.kd139.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow139 PRE_first_tail_x15_r0_body.cnn1139 PRE_first_tail_x15_r0_body.fnordI139 PRE_first_tail_x15_r0_body.fnordK139 PRE_first_tail_x15_r0_body.fnordL139
kernel_rfl PRE_first_tail_x15_r0_body.fi139 : PRE_first_tail_x15_r0_body.cli139.all (pnB PRE_first_tail_x15_r0_body.cx0_139.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii139 : PRE_first_tail_x15_r0_body.cli139.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_139.mlx.items.get (PRE_first_tail_x15_r0_body.kappa139.node k) = (PRE_first_tail_x15_r0_body.cx0_139.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa139.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.kd139 PRE_first_tail_x15_r0_body.khinv139 PRE_first_tail_x15_r0_body.kninv139 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.cx1_139.mlx (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo139 PRE_first_tail_x15_r0_body.cln139 PRE_first_tail_x15_r0_body.cli139 PRE_first_tail_x15_r0_body.cwS139 PRE_first_tail_x15_r0_body.cnS139 PRE_first_tail_x15_r0_body.ciS139 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0139, PRE_first_tail_x15_r0_body.cnh1139, PRE_first_tail_x15_r0_body.cnn0139, PRE_first_tail_x15_r0_body.cnn1139, PRE_first_tail_x15_r0_body.cplo139, PRE_first_tail_x15_r0_body.ccnt139, PRE_first_tail_x15_r0_body.cnband139, PRE_first_tail_x15_r0_body.chbelow139, PRE_first_tail_x15_r0_body.chren139, PRE_first_tail_x15_r0_body.cband139, PRE_first_tail_x15_r0_body.cnh1pos139, PRE_first_tail_x15_r0_body.cnren139, PRE_first_tail_x15_r0_body.cnlow139, PRE_first_tail_x15_r0_body.cabs0a139, PRE_first_tail_x15_r0_body.cabs0b139, PRE_first_tail_x15_r0_body.ctok1139, PRE_first_tail_x15_r0_body.cpend139, PRE_first_tail_x15_r0_body.cerrh139, PRE_first_tail_x15_r0_body.cfiles139, PRE_first_tail_x15_r0_body.carch139, PRE_first_tail_x15_r0_body.csizes139, PRE_first_tail_x15_r0_body.cwired139, PRE_first_tail_x15_r0_body.cfix139, clean, PRE_first_tail_x15_r0_body.fcxn139, PRE_first_tail_x15_r0_body.fcnn139, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0139, PRE_first_tail_x15_r0_body.fnk139, PRE_first_tail_x15_r0_body.ckA139, PRE_first_tail_x15_r0_body.cobjsK139, PRE_first_tail_x15_r0_body.cnodesK139, PRE_first_tail_x15_r0_body.citemsK139, PRE_first_tail_x15_r0_body.f1A139, PRE_first_tail_x15_r0_body.f1O139, PRE_first_tail_x15_r0_body.f1N139, PRE_first_tail_x15_r0_body.f1I139, PRE_first_tail_x15_r0_body.fbd139, PRE_first_tail_x15_r0_body.fincW139, PRE_first_tail_x15_r0_body.fincI139, PRE_first_tail_x15_r0_body.fincN139, PRE_first_tail_x15_r0_body.flnF139, PRE_first_tail_x15_r0_body.fh139, PRE_first_tail_x15_r0_body.fo139, PRE_first_tail_x15_r0_body.fok139, PRE_first_tail_x15_r0_body.fnd139, PRE_first_tail_x15_r0_body.fp139, PRE_first_tail_x15_r0_body.fnord139, PRE_first_tail_x15_r0_body.fi139, PRE_first_tail_x15_r0_body.fii139⟩
theorem PRE_first_tail_x15_r0_body.cnshift139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx) : NShift PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.cx0_139 PRE_first_tail_x15_r0_body.cx1_139 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost139 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0139 PRE_first_tail_x15_r0_body.ckn1139 PRE_first_tail_x15_r0_body.ckheap139 PRE_first_tail_x15_r0_body.ckpl139)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1347.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1347.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1347.ffi) = some PRE_first_tail_x15_r0_body.fxC_139
kernel_rfl PRE_first_tail_x15_r0_body.okrC_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1347.ffi) = some PRE_first_tail_x15_r0_body.krC_139
noncomputable def PRE_first_tail_x15_r0_body.fx0_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1349.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1349.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1349.ffi) = some PRE_first_tail_x15_r0_body.fx0_139
kernel_rfl PRE_first_tail_x15_r0_body.okr0_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1349.ffi) = some PRE_first_tail_x15_r0_body.kr0_139
noncomputable def PRE_first_tail_x15_r0_body.fx1_139 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1348.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_139 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1348.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_139 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1348.ffi) = some PRE_first_tail_x15_r0_body.fx1_139
kernel_rfl PRE_first_tail_x15_r0_body.okr1_139 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1348.ffi) = some PRE_first_tail_x15_r0_body.kr1_139
kernel_rfl PRE_first_tail_x15_r0_body.ff0139 : PRE_first_tail_x15_r0_body.fx0_139 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_139 (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_139.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1139 : PRE_first_tail_x15_r0_body.fx1_139 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_139 (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_139.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck139 : freedLB PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.fx0_139 PRE_first_tail_x15_r0_body.fx1_139 PRE_first_tail_x15_r0_body.clo139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0139 : PRE_first_tail_x15_r0_body.kr0_139.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.flags (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_139.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0139 : PRE_first_tail_x15_r0_body.kr0_139.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.targs (PRE_first_tail_x15_r0_body.clo139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_139.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1139 : PRE_first_tail_x15_r0_body.kr1_139.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.flags (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_139.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1139 : PRE_first_tail_x15_r0_body.kr1_139.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_139.targs (PRE_first_tail_x15_r0_body.cwS139.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_139.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck139 : krecLB PRE_first_tail_x15_r0_body.kappa139 6023 PRE_first_tail_x15_r0_body.cx0_139.mlx PRE_first_tail_x15_r0_body.kr0_139 PRE_first_tail_x15_r0_body.kr1_139 PRE_first_tail_x15_r0_body.clo139 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn139 : Nat.ble 6023 6023 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge139 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1348.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1349.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR139 : pendRegB PRE_first_tail_x15_r0_body.kappa139 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe139 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1349.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1348.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift139 (clean : Conv.NClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P139.NL) (cl : SSt (· < 6023) PRE_first_tail_x15_r0_body.cx0_139.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_139.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_139.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_139.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1347.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_139.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P139 6023 PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.s1349.ffi PRE_first_tail_x15_r0_body.s1348.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift139 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue139, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp139 t ht),
    PRE_first_tail_x15_r0_body.cbridge139,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1349.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1348.ffi) (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_139 PRE_first_tail_x15_r0_body.ofx1_139 hobjC PRE_first_tail_x15_r0_body.ff0139 PRE_first_tail_x15_r0_body.ff1139 PRE_first_tail_x15_r0_body.ffck139,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1349.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1348.ffi) (PRE_first_tail_x15_r0_body.cfoot139 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_139 PRE_first_tail_x15_r0_body.okr1_139 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn139) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0139 PRE_first_tail_x15_r0_body.fkt0139 PRE_first_tail_x15_r0_body.fkf1139 PRE_first_tail_x15_r0_body.fkt1139 PRE_first_tail_x15_r0_body.fkck139,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0139 PRE_first_tail_x15_r0_body.cnh1139 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe139) PRE_first_tail_x15_r0_body.cpendR139⟩

end Host.Load.Run.Tpl
end

section -- st139/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st139 0
host_stream_state PRE_first_tail_x15_r0_body.st139 1
host_stream_state PRE_first_tail_x15_r0_body.st139 2
end Host.Load.Run.Tpl
end

section -- Site139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 139 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g139__g140` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1347`, the merged state `PRE_first_tail_x15_r0_body.s1348`,
the site template `PRE_first_tail_x15_r0_body.st139` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1349`: the merge.
The footprint's facts are in `SiteF139`, the compaction's in `SiteC139`, `SiteK139`, `SiteNa139`, `SiteNb139`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso139 : PRE_first_tail_x15_r0_body.st139.s0 = { PRE_first_tail_x15_r0_body.s1347 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs139 : List Frame := PRE_first_tail_x15_r0_body.s1347.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_139 : PRE_first_tail_x15_r0_body.S1347.tab.length = 6023
kernel_rfl PRE_first_tail_x15_r0_body.tab0_139 : PRE_first_tail_x15_r0_body.st139.S0.tab = PRE_first_tail_x15_r0_body.S1347.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws139 : List Nat := [3352, 3353]
kernel_rfl PRE_first_tail_x15_r0_body.fresh139 : (PRE_first_tail_x15_r0_body.S1347.tab.all fun e => PRE_first_tail_x15_r0_body.ws139.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1347.oracle.all fun q => PRE_first_tail_x15_r0_body.ws139.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab139 : PRE_first_tail_x15_r0_body.S1348.tab = PRE_first_tail_x15_r0_body.S1347.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws139
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen139 : PRE_first_tail_x15_r0_body.st139.S2.tab.length - PRE_first_tail_x15_r0_body.st139.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged139`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap139 : PRE_first_tail_x15_r0_body.s1348.heap = PRE_first_tail_x15_r0_body.st139.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext139 : PRE_first_tail_x15_r0_body.s1348.next = PRE_first_tail_x15_r0_body.st139.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl139 : PRE_first_tail_x15_r0_body.s1348.ctl = PRE_first_tail_x15_r0_body.st139.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack139 : PRE_first_tail_x15_r0_body.s1348.stack = PRE_first_tail_x15_r0_body.st139.s2.stack ++ PRE_first_tail_x15_r0_body.s1347.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs139 : PRE_first_tail_x15_r0_body.s1348.jobs = PRE_first_tail_x15_r0_body.st139.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi139 : PRE_first_tail_x15_r0_body.s1348.ffi = PRE_first_tail_x15_r0_body.st139.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace139 : PRE_first_tail_x15_r0_body.s1348.trace = PRE_first_tail_x15_r0_body.st139.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores139 : PRE_first_tail_x15_r0_body.s1348.stores = PRE_first_tail_x15_r0_body.st139.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 139 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived139 : PRE_first_tail_x15_r0_body.nr139.map (fun r => nth? PRE_first_tail_x15_r0_body.st139.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo139 : PRE_first_tail_x15_r0_body.nr139.all (Nat.ble 6023) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj139 : PRE_first_tail_x15_r0_body.cws139.all (fun c => !PRE_first_tail_x15_r0_body.ws139.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ139 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws139 PRE_first_tail_x15_r0_body.crs139 PRE_first_tail_x15_r0_body.ws139

end Host.Load.Run.Tpl
end

section -- st139/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st139`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st139.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st139.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st139.s2.heap PRE_first_tail_x15_r0_body.st139.wrR ++ freshOf PRE_first_tail_x15_r0_body.st139.s2.heap PRE_first_tail_x15_r0_body.st139.s0.next PRE_first_tail_x15_r0_body.st139.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st139.wr : List Nat := PRE_first_tail_x15_r0_body.st139.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st139.heapFoot : PRE_first_tail_x15_r0_body.st139.s2.heap = setAll PRE_first_tail_x15_r0_body.st139.s0.heap PRE_first_tail_x15_r0_body.st139.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st139.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st139.s0.next PRE_first_tail_x15_r0_body.st139.s2.next = true
theorem PRE_first_tail_x15_r0_body.st139.grows : PRE_first_tail_x15_r0_body.st139.s0.next ≤ PRE_first_tail_x15_r0_body.st139.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st139.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st139.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st139.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st139.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st139.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st139.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st139.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st139.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st139.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st139.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st139.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st139.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 139 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB139 : nodupT PRE_first_tail_x15_r0_body.st139.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup139 : PRE_first_tail_x15_r0_body.st139.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB139).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB139 : PRE_first_tail_x15_r0_body.st139.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound139 : ∀ b ∈ PRE_first_tail_x15_r0_body.st139.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB139 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr139 := PRE_first_tail_x15_r0_body.st139.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq139 : PRE_first_tail_x15_r0_body.st139.s2.trace = PRE_first_tail_x15_r0_body.trFr139 ++ PRE_first_tail_x15_r0_body.st139.s0.trace
theorem PRE_first_tail_x15_r0_body.trace139 : ∃ fr, PRE_first_tail_x15_r0_body.st139.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st139.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq139⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide139 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB139 : (PRE_first_tail_x15_r0_body.wide139.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st139.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix139 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide139, WFix Map.id (Present PRE_first_tail_x15_r0_body.st139.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB139 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 139 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1348`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO139 : PRE_first_tail_x15_r0_body.st139.S0.oracle = PRE_first_tail_x15_r0_body.st139.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B139 : PRE_first_tail_x15_r0_body.st139.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st139.s0.next || (PRE_first_tail_x15_r0_body.st139.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot139 : Conv.StageFoot PRE_first_tail_x15_r0_body.st139.wr PRE_first_tail_x15_r0_body.st139.s0 PRE_first_tail_x15_r0_body.st139.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st139.heapFoot PRE_first_tail_x15_r0_body.wrNodup139 PRE_first_tail_x15_r0_body.wrBound139 PRE_first_tail_x15_r0_body.wr0B139 PRE_first_tail_x15_r0_body.st139.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged139 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st139.F.S → PRE_first_tail_x15_r0_body.st139.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st139.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st139.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs139 PRE_first_tail_x15_r0_body.st139.wr PRE_first_tail_x15_r0_body.s1347 PRE_first_tail_x15_r0_body.st139.s2 PRE_first_tail_x15_r0_body.st139.s0
      PRE_first_tail_x15_r0_body.st139.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st139.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1348 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso139 PRE_first_tail_x15_r0_body.stFoot139 PRE_first_tail_x15_r0_body.wrNodup139 PRE_first_tail_x15_r0_body.wrBound139 PRE_first_tail_x15_r0_body.trace139 PRE_first_tail_x15_r0_body.mheap139
    PRE_first_tail_x15_r0_body.mnext139 PRE_first_tail_x15_r0_body.mctl139 PRE_first_tail_x15_r0_body.mstack139 PRE_first_tail_x15_r0_body.mjobs139 PRE_first_tail_x15_r0_body.mffi139 PRE_first_tail_x15_r0_body.mtrace139 PRE_first_tail_x15_r0_body.mstores139 h

def PRE_first_tail_x15_r0_body.arrEl139_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE139_2665 : arrOf PRE_first_tail_x15_r0_body.s1348 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl139_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA139_2665 : isArrB PRE_first_tail_x15_r0_body.s1348 2665 = true
theorem PRE_first_tail_x15_r0_body.arr139_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1348.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl139_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE139_2665 PRE_first_tail_x15_r0_body.arrA139_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN139_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl139_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR139_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl139_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN139_2665

def PRE_first_tail_x15_r0_body.arrEl139_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE139_2673467 : arrOf PRE_first_tail_x15_r0_body.s1348 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl139_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA139_2673467 : isArrB PRE_first_tail_x15_r0_body.s1348 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr139_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1348.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl139_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE139_2673467 PRE_first_tail_x15_r0_body.arrA139_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN139_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl139_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR139_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl139_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN139_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k139 : isArrB PRE_first_tail_x15_r0_body.s1348 4910 = false
theorem PRE_first_tail_x15_r0_body.keep139 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1348 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k139 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr139_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl139_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ139
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 139 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1347`, the merged
state `PRE_first_tail_x15_r0_body.s1348`, the canonical state `PRE_first_tail_x15_r0_body.s1349`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl139 : PRE_first_tail_x15_r0_body.pl139.all (Nat.ble PRE_first_tail_x15_r0_body.s1347.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd139 : nodupT PRE_first_tail_x15_r0_body.pl139 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1139 : Nat.ble PRE_first_tail_x15_r0_body.s1347.next 2784049 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst139 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1347.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn139 : PRE_first_tail_x15_r0_body.s1349.next = PRE_first_tail_x15_r0_body.s1347.next + PRE_first_tail_x15_r0_body.pl139.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn139 : PRE_first_tail_x15_r0_body.s1348.next = 2784049
kernel_rfl PRE_first_tail_x15_r0_body.zgrow139 : Nat.ble PRE_first_tail_x15_r0_body.s1349.next PRE_first_tail_x15_r0_body.s1348.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh139 : PRE_first_tail_x15_r0_body.S1347.tab.all (fun e => PRE_first_tail_x15_r0_body.cws139.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd139 : nodupT PRE_first_tail_x15_r0_body.cws139 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi139 : PRE_first_tail_x15_r0_body.nr139.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1348.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt139 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1347.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg139_2665 : PRE_first_tail_x15_r0_body.s1349.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1349 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk139_2665 : (objOf PRE_first_tail_x15_r0_body.s1349 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm139_2665 : PRE_first_tail_x15_r0_body.s1348.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa139.obj (objOf PRE_first_tail_x15_r0_body.s1349 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1348 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg139_2673467 : PRE_first_tail_x15_r0_body.s1349.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1349 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk139_2673467 : (objOf PRE_first_tail_x15_r0_body.s1349 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm139_2673467 : PRE_first_tail_x15_r0_body.s1348.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa139.obj (objOf PRE_first_tail_x15_r0_body.s1349 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1348 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw139_4910 : (PRE_first_tail_x15_r0_body.s1349.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw139_2673472 : (PRE_first_tail_x15_r0_body.s1349.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw139_2673473 : (PRE_first_tail_x15_r0_body.s1349.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd139 : PRE_first_tail_x15_r0_body.cl139.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr139 : PRE_first_tail_x15_r0_body.st139.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1347.next || PRE_first_tail_x15_r0_body.cl139.contains b) = true
def PRE_first_tail_x15_r0_body.zl139 : List Nat := PRE_first_tail_x15_r0_body.cl139.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE139 : PRE_first_tail_x15_r0_body.zl139.map (fun a => PRE_first_tail_x15_r0_body.s1348.heap.get (PRE_first_tail_x15_r0_body.kappa139.a a)) = PRE_first_tail_x15_r0_body.zl139.map (fun a => (PRE_first_tail_x15_r0_body.s1349.heap.get a).map PRE_first_tail_x15_r0_body.kappa139.hobj)
theorem PRE_first_tail_x15_r0_body.zimg139 : HeapImg PRE_first_tail_x15_r0_body.kappa139 PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.s1348 PRE_first_tail_x15_r0_body.zl139 := PRE_first_tail_x15_r0_body.zimgE139
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl139 : PRE_first_tail_x15_r0_body.s1348.ctl = PRE_first_tail_x15_r0_body.kappa139.ctl PRE_first_tail_x15_r0_body.s1349.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack139 : PRE_first_tail_x15_r0_body.s1348.stack = PRE_first_tail_x15_r0_body.s1349.stack.map PRE_first_tail_x15_r0_body.kappa139.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs139 : PRE_first_tail_x15_r0_body.s1348.jobs = PRE_first_tail_x15_r0_body.s1349.jobs.map PRE_first_tail_x15_r0_body.kappa139.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores139 : PRE_first_tail_x15_r0_body.s1348.stores = PRE_first_tail_x15_r0_body.kappa139.stores PRE_first_tail_x15_r0_body.s1349.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots139 : checkRootsSupp PRE_first_tail_x15_r0_body.s1349 6023 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC139 : PRE_first_tail_x15_r0_body.S1347.tab.length + PRE_first_tail_x15_r0_body.cws139.length = 6023
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap139 : PRE_first_tail_x15_r0_body.kappa139 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1347.next 2784049 PRE_first_tail_x15_r0_body.S1347.tab.length PRE_first_tail_x15_r0_body.pl139 (PRE_first_tail_x15_r0_body.nr139.map NumV.ref) PRE_first_tail_x15_r0_body.kd139.big
  PRE_first_tail_x15_r0_body.kd139.region PRE_first_tail_x15_r0_body.kd139.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin139 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1349.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc139 : Conv.jcleanListB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1349 PRE_first_tail_x15_r0_body.cl139 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB139 : noBigRootsP (fun i => !Conv.oldBigB (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1349.trace PRE_first_tail_x15_r0_body.s1349 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm139 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18051 = true
theorem PRE_first_tail_x15_r0_body.cjcl139 (h : Conv.JClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1347) : Conv.JClean (⟨20942, 18051, 2784047, 6023⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1349 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle139)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap139 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd139 a ha)) PRE_first_tail_x15_r0_body.zjc139

end Host.Load.Run.Tpl
end

section -- st139/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st139.bodyLast from PRE_first_tail_x15_r0_body.st139.s1 to PRE_first_tail_x15_r0_body.st139.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st139.F PRE_first_tail_x15_r0_body.st139.s1).run PRE_first_tail_x15_r0_body.st139.S1 = some (PRE_first_tail_x15_r0_body.st139.s2, PRE_first_tail_x15_r0_body.st139.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st139.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st139.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st139.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st139.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st139/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st139.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st139.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st139.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st139.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st139.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st139.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st139.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st139.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st139.s0 PRE_first_tail_x15_r0_body.st139.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st139.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st139.s1 PRE_first_tail_x15_r0_body.st139.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st139/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st139.bodyK0F from PRE_first_tail_x15_r0_body.st139.s0 to PRE_first_tail_x15_r0_body.st139.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st139.F (PRE_first_tail_x15_r0_body.st139.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st139.ks 0).getD 0) PRE_first_tail_x15_r0_body.st139.s0 PRE_first_tail_x15_r0_body.st139.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st139.s1, PRE_first_tail_x15_r0_body.st139.S1)
theorem PRE_first_tail_x15_r0_body.st139.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st139.F (PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st139.ks 0).getD 0) PRE_first_tail_x15_r0_body.st139.s0 PRE_first_tail_x15_r0_body.st139.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st139.s1, PRE_first_tail_x15_r0_body.st139.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st139.bodyOkLN_ok PRE_first_tail_x15_r0_body.st139.bodyK0F
end Host.Load.Run.Tpl
end

section -- st139/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st139.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st139.F (PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows) 27 PRE_first_tail_x15_r0_body.st139.s0 PRE_first_tail_x15_r0_body.st139.S0 = some (PRE_first_tail_x15_r0_body.st139.s1, PRE_first_tail_x15_r0_body.st139.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st139.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st139.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st139.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st139.F (PRE_first_tail_x15_r0_body.st139.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st139.s0
  S0 := PRE_first_tail_x15_r0_body.st139.S0
  s1 := PRE_first_tail_x15_r0_body.st139.s1
  S1 := PRE_first_tail_x15_r0_body.st139.S1
  s2 := PRE_first_tail_x15_r0_body.st139.s2
  S2 := PRE_first_tail_x15_r0_body.st139.S2
  n := 27
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st139.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st139.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st139.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st139.bodyHalt
  last := PRE_first_tail_x15_r0_body.st139.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st139.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 140 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1353` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa140` into the merged state
`PRE_first_tail_x15_r0_body.s1352`. -/

def PRE_first_tail_x15_r0_body.pl140 : List Nat := [2784354]
def PRE_first_tail_x15_r0_body.nr140 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd140 : RData :=
  ⟨2784336, 2784355, Stage.setAll PTrie.nil [(2784335, 2784354)], Stage.setAll PTrie.nil [],
   20949, 20949, 18055, 18055, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa140 : Map :=
  Conv.Map.compact 2784335 2784355 6040 PRE_first_tail_x15_r0_body.pl140 (PRE_first_tail_x15_r0_body.nr140.map NumV.ref) PRE_first_tail_x15_r0_body.kd140.big
    PRE_first_tail_x15_r0_body.kd140.region PRE_first_tail_x15_r0_body.kd140.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws140 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs140 : List SymE := PRE_first_tail_x15_r0_body.nr140.map fun r => (nth? PRE_first_tail_x15_r0_body.S1352.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta140 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws140 PRE_first_tail_x15_r0_body.crs140
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB140 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab140 : PRE_first_tail_x15_r0_body.S1353.tab = PRE_first_tail_x15_r0_body.S1351.tab ++ PRE_first_tail_x15_r0_body.cws140.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace140 : PRE_first_tail_x15_r0_body.s1353.trace = PRE_first_tail_x15_r0_body.s1351.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext140 : PRE_first_tail_x15_r0_body.s1353.next = 2784336
kernel_rfl PRE_first_tail_x15_r0_body.ccounters140 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.nnext) = (20949, 18055)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa140.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.tokens.all (bSN 6040) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean140 : Conv.cleanListB 20949 131072 (fun r => Nat.ble 83796 r) PRE_first_tail_x15_r0_body.s1353
    (PRE_first_tail_x15_r0_body.wrB140 ++ (List.range 1).map (2784335 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs140 : bigsOutB 20949 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl140`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl140 : List Nat := [2665, 2673467, 2784335]
def PRE_first_tail_x15_r0_body.clo140 : List Nat := []
def PRE_first_tail_x15_r0_body.cln140 : List Nat := []
def PRE_first_tail_x15_r0_body.cli140 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap140 : PRE_first_tail_x15_r0_body.s1353.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1351.heap (PRE_first_tail_x15_r0_body.cl140.filterMap fun a => (PRE_first_tail_x15_r0_body.s1353.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe140 : Nat.ble PRE_first_tail_x15_r0_body.s1351.next PRE_first_tail_x15_r0_body.s1353.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP140 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp140 : Conv.suppListB PRE_first_tail_x15_r0_body.s1353 6040 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound140 : Conv.boundListB PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst140 : Conv.sstListB 6040 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cli140 = true

end Host.Load.Run.Tpl
end

section -- SiteCl140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA140 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd140 : (PRE_first_tail_x15_r0_body.clo140 ++ PRE_first_tail_x15_r0_body.cln140 ++ PRE_first_tail_x15_r0_body.cli140).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle140 : Conv.Cnt.leB (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck140 : Conv.ncleanListB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.cli140 = true
theorem PRE_first_tail_x15_r0_body.cncl140 (h : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx) : Conv.NClean (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle140 PRE_first_tail_x15_r0_body.ckA140 PRE_first_tail_x15_r0_body.cobjsK140 PRE_first_tail_x15_r0_body.cnodesK140 PRE_first_tail_x15_r0_body.citemsK140 PRE_first_tail_x15_r0_body.cbd140 PRE_first_tail_x15_r0_body.cck140

end Host.Load.Run.Tpl
end

section -- SiteS140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 140 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc140 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P140 : LoadP := PRE_first_tail_x15_r0_body.Pc140.raise 18055
kernel_rfl PRE_first_tail_x15_r0_body.craise140 : Nat.ble PRE_first_tail_x15_r0_body.Pc140.N0 18055 = true
theorem PRE_first_tail_x15_r0_body.raised140 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc140 PRE_first_tail_x15_r0_body.P140 :=
  .inr ⟨18055, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise140, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_140 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_140 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi)
def PRE_first_tail_x15_r0_body.khinv140 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv140 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS140 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS140 : List Nat := List.range' 18055 0
def PRE_first_tail_x15_r0_body.ciS140 : List Nat := [] ++ List.range' 18055 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0140 : PRE_first_tail_x15_r0_body.kd140.nh0 = PRE_first_tail_x15_r0_body.cx0_140.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1140 : PRE_first_tail_x15_r0_body.kd140.nh1 = PRE_first_tail_x15_r0_body.cx1_140.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0140 : PRE_first_tail_x15_r0_body.kd140.nn0 = PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1140 : PRE_first_tail_x15_r0_body.kd140.nn1 = PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo140 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P140.lo && Nat.ble PRE_first_tail_x15_r0_body.P140.lo PRE_first_tail_x15_r0_body.cx0_140.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P140.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P140.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt140 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_140.mlx.next PRE_first_tail_x15_r0_body.cx1_140.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband140 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P140.NL && Nat.ble PRE_first_tail_x15_r0_body.P140.NL PRE_first_tail_x15_r0_body.P140.N0 && Nat.ble PRE_first_tail_x15_r0_body.P140.N0 PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow140 : PRE_first_tail_x15_r0_body.kd140.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren140 : checkRenG PRE_first_tail_x15_r0_body.kd140.hnd PRE_first_tail_x15_r0_body.khinv140 (phB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband140 : PRE_first_tail_x15_r0_body.kd140.checkBand PRE_first_tail_x15_r0_body.P140.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos140 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd140.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren140 : checkRenG PRE_first_tail_x15_r0_body.kd140.node PRE_first_tail_x15_r0_body.kninv140 (pnB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P140.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd140.nodeF j) PRE_first_tail_x15_r0_body.cx1_140.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a140 : PRE_first_tail_x15_r0_body.cx0_140.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b140 : PRE_first_tail_x15_r0_body.cx0_140.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.pending = PRE_first_tail_x15_r0_body.cx0_140.mlx.pending.map PRE_first_tail_x15_r0_body.kappa140.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.errh = PRE_first_tail_x15_r0_body.cx0_140.mlx.errh.map PRE_first_tail_x15_r0_body.kappa140.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.files = PRE_first_tail_x15_r0_body.cx0_140.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.arch = PRE_first_tail_x15_r0_body.cx0_140.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_140.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.wired = PRE_first_tail_x15_r0_body.cx0_140.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost140 : PRE_first_tail_x15_r0_body.cx1_140.host = PRE_first_tail_x15_r0_body.cx0_140.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd140`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0140 : PRE_first_tail_x15_r0_body.kd140.n0 = 2784336
kernel_rfl PRE_first_tail_x15_r0_body.ckn1140 : PRE_first_tail_x15_r0_body.kd140.n1 = 2784355
kernel_rfl PRE_first_tail_x15_r0_body.ckheap140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.heap).all (fun x => Nat.ble 2784335 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl140 : (List.range 1).all (fun j => decide (PRE_first_tail_x15_r0_body.kd140.heap.get (2784335 + j) = nth? PRE_first_tail_x15_r0_body.pl140 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja140 : Nat.ble 2784335 2784335 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn140 : Nat.ble 6040 6040 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD140 : Nat.ble 2784335 PRE_first_tail_x15_r0_body.kd140.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn140 : Nat.ble 20949 PRE_first_tail_x15_r0_body.kd140.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn140 : Nat.ble 18055 PRE_first_tail_x15_r0_body.kd140.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb140 : Nat.ble 20949 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.heap).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.hnd).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (Nat.ble (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix140 : Conv.FixOld (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa140 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn140) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb140) PRE_first_tail_x15_r0_body.fheap140 PRE_first_tail_x15_r0_body.fhnd140 PRE_first_tail_x15_r0_body.fnode140
kernel_rfl PRE_first_tail_x15_r0_body.fcxn140 : (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn140 : (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0140 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_140.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_140.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I140 : PRE_first_tail_x15_r0_body.cx1_140.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS140.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd140 : (PRE_first_tail_x15_r0_body.clo140 ++ PRE_first_tail_x15_r0_body.cln140 ++ PRE_first_tail_x15_r0_body.cli140 ++ PRE_first_tail_x15_r0_body.cwS140 ++ PRE_first_tail_x15_r0_body.cnS140 ++ PRE_first_tail_x15_r0_body.ciS140).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW140 : PRE_first_tail_x15_r0_body.cwS140.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo140.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI140 : PRE_first_tail_x15_r0_body.ciS140.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli140.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN140 : PRE_first_tail_x15_r0_body.cnS140.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF140 : PRE_first_tail_x15_r0_body.cln140.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh140 : PRE_first_tail_x15_r0_body.clo140.all (handleOK PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140.lo PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo140 : PRE_first_tail_x15_r0_body.clo140.map (fun h => PRE_first_tail_x15_r0_body.cx1_140.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa140.handle h)) = PRE_first_tail_x15_r0_body.clo140.map (fun h => (PRE_first_tail_x15_r0_body.cx0_140.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa140.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok140 : PRE_first_tail_x15_r0_body.clo140.all (objOK PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140.NL PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd140 : PRE_first_tail_x15_r0_body.cln140.all (nodeOKF PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.P140 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp140 : ((PRE_first_tail_x15_r0_body.cln140.filter (fullB PRE_first_tail_x15_r0_body.P140))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_140.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa140.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln140.filter (fullB PRE_first_tail_x15_r0_body.P140))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_140.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa140.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI140 : incrB PRE_first_tail_x15_r0_body.kd140.nodeF (List.range' 18055 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK140 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all (fun k => Nat.ble 18055 k && Nat.blt k 18055) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL140 : (PRE_first_tail_x15_r0_body.cln140.filter (Nat.ble PRE_first_tail_x15_r0_body.P140.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd140.nodeF i) && (Nat.blt i 18055 || Nat.ble PRE_first_tail_x15_r0_body.kd140.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord140 : (PRE_first_tail_x15_r0_body.cln140.filter (Nat.ble PRE_first_tail_x15_r0_body.P140.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd140.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd140.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd140.nodeF j) (PRE_first_tail_x15_r0_body.kd140.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow140 PRE_first_tail_x15_r0_body.cnn1140 PRE_first_tail_x15_r0_body.fnordI140 PRE_first_tail_x15_r0_body.fnordK140 PRE_first_tail_x15_r0_body.fnordL140
kernel_rfl PRE_first_tail_x15_r0_body.fi140 : PRE_first_tail_x15_r0_body.cli140.all (pnB PRE_first_tail_x15_r0_body.cx0_140.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii140 : PRE_first_tail_x15_r0_body.cli140.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_140.mlx.items.get (PRE_first_tail_x15_r0_body.kappa140.node k) = (PRE_first_tail_x15_r0_body.cx0_140.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa140.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.kd140 PRE_first_tail_x15_r0_body.khinv140 PRE_first_tail_x15_r0_body.kninv140 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.cx1_140.mlx (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo140 PRE_first_tail_x15_r0_body.cln140 PRE_first_tail_x15_r0_body.cli140 PRE_first_tail_x15_r0_body.cwS140 PRE_first_tail_x15_r0_body.cnS140 PRE_first_tail_x15_r0_body.ciS140 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0140, PRE_first_tail_x15_r0_body.cnh1140, PRE_first_tail_x15_r0_body.cnn0140, PRE_first_tail_x15_r0_body.cnn1140, PRE_first_tail_x15_r0_body.cplo140, PRE_first_tail_x15_r0_body.ccnt140, PRE_first_tail_x15_r0_body.cnband140, PRE_first_tail_x15_r0_body.chbelow140, PRE_first_tail_x15_r0_body.chren140, PRE_first_tail_x15_r0_body.cband140, PRE_first_tail_x15_r0_body.cnh1pos140, PRE_first_tail_x15_r0_body.cnren140, PRE_first_tail_x15_r0_body.cnlow140, PRE_first_tail_x15_r0_body.cabs0a140, PRE_first_tail_x15_r0_body.cabs0b140, PRE_first_tail_x15_r0_body.ctok1140, PRE_first_tail_x15_r0_body.cpend140, PRE_first_tail_x15_r0_body.cerrh140, PRE_first_tail_x15_r0_body.cfiles140, PRE_first_tail_x15_r0_body.carch140, PRE_first_tail_x15_r0_body.csizes140, PRE_first_tail_x15_r0_body.cwired140, PRE_first_tail_x15_r0_body.cfix140, clean, PRE_first_tail_x15_r0_body.fcxn140, PRE_first_tail_x15_r0_body.fcnn140, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0140, PRE_first_tail_x15_r0_body.fnk140, PRE_first_tail_x15_r0_body.ckA140, PRE_first_tail_x15_r0_body.cobjsK140, PRE_first_tail_x15_r0_body.cnodesK140, PRE_first_tail_x15_r0_body.citemsK140, PRE_first_tail_x15_r0_body.f1A140, PRE_first_tail_x15_r0_body.f1O140, PRE_first_tail_x15_r0_body.f1N140, PRE_first_tail_x15_r0_body.f1I140, PRE_first_tail_x15_r0_body.fbd140, PRE_first_tail_x15_r0_body.fincW140, PRE_first_tail_x15_r0_body.fincI140, PRE_first_tail_x15_r0_body.fincN140, PRE_first_tail_x15_r0_body.flnF140, PRE_first_tail_x15_r0_body.fh140, PRE_first_tail_x15_r0_body.fo140, PRE_first_tail_x15_r0_body.fok140, PRE_first_tail_x15_r0_body.fnd140, PRE_first_tail_x15_r0_body.fp140, PRE_first_tail_x15_r0_body.fnord140, PRE_first_tail_x15_r0_body.fi140, PRE_first_tail_x15_r0_body.fii140⟩
theorem PRE_first_tail_x15_r0_body.cnshift140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx) : NShift PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.cx0_140 PRE_first_tail_x15_r0_body.cx1_140 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost140 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0140 PRE_first_tail_x15_r0_body.ckn1140 PRE_first_tail_x15_r0_body.ckheap140 PRE_first_tail_x15_r0_body.ckpl140)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1351.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1351.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1351.ffi) = some PRE_first_tail_x15_r0_body.fxC_140
kernel_rfl PRE_first_tail_x15_r0_body.okrC_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1351.ffi) = some PRE_first_tail_x15_r0_body.krC_140
noncomputable def PRE_first_tail_x15_r0_body.fx0_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1353.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1353.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1353.ffi) = some PRE_first_tail_x15_r0_body.fx0_140
kernel_rfl PRE_first_tail_x15_r0_body.okr0_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1353.ffi) = some PRE_first_tail_x15_r0_body.kr0_140
noncomputable def PRE_first_tail_x15_r0_body.fx1_140 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1352.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_140 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1352.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_140 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1352.ffi) = some PRE_first_tail_x15_r0_body.fx1_140
kernel_rfl PRE_first_tail_x15_r0_body.okr1_140 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1352.ffi) = some PRE_first_tail_x15_r0_body.kr1_140
kernel_rfl PRE_first_tail_x15_r0_body.ff0140 : PRE_first_tail_x15_r0_body.fx0_140 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_140 (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_140.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1140 : PRE_first_tail_x15_r0_body.fx1_140 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_140 (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_140.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck140 : freedLB PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.fx0_140 PRE_first_tail_x15_r0_body.fx1_140 PRE_first_tail_x15_r0_body.clo140 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0140 : PRE_first_tail_x15_r0_body.kr0_140.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.flags (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_140.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0140 : PRE_first_tail_x15_r0_body.kr0_140.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.targs (PRE_first_tail_x15_r0_body.clo140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_140.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1140 : PRE_first_tail_x15_r0_body.kr1_140.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.flags (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_140.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1140 : PRE_first_tail_x15_r0_body.kr1_140.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_140.targs (PRE_first_tail_x15_r0_body.cwS140.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_140.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck140 : krecLB PRE_first_tail_x15_r0_body.kappa140 6040 PRE_first_tail_x15_r0_body.cx0_140.mlx PRE_first_tail_x15_r0_body.kr0_140 PRE_first_tail_x15_r0_body.kr1_140 PRE_first_tail_x15_r0_body.clo140 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn140 : Nat.ble 6040 6040 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge140 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1352.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1353.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR140 : pendRegB PRE_first_tail_x15_r0_body.kappa140 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe140 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1353.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1352.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift140 (clean : Conv.NClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P140.NL) (cl : SSt (· < 6040) PRE_first_tail_x15_r0_body.cx0_140.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_140.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_140.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_140.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1351.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_140.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P140 6040 PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1353.ffi PRE_first_tail_x15_r0_body.s1352.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift140 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue140, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp140 t ht),
    PRE_first_tail_x15_r0_body.cbridge140,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1353.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1352.ffi) (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_140 PRE_first_tail_x15_r0_body.ofx1_140 hobjC PRE_first_tail_x15_r0_body.ff0140 PRE_first_tail_x15_r0_body.ff1140 PRE_first_tail_x15_r0_body.ffck140,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1353.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1352.ffi) (PRE_first_tail_x15_r0_body.cfoot140 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_140 PRE_first_tail_x15_r0_body.okr1_140 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn140) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0140 PRE_first_tail_x15_r0_body.fkt0140 PRE_first_tail_x15_r0_body.fkf1140 PRE_first_tail_x15_r0_body.fkt1140 PRE_first_tail_x15_r0_body.fkck140,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0140 PRE_first_tail_x15_r0_body.cnh1140 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe140) PRE_first_tail_x15_r0_body.cpendR140⟩

end Host.Load.Run.Tpl
end

section -- st140/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st140 0
host_stream_state PRE_first_tail_x15_r0_body.st140 1
host_stream_state PRE_first_tail_x15_r0_body.st140 2
end Host.Load.Run.Tpl
end

section -- Site140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 140 of chain `PRE_first_tail_x15_r0_body`: `plan__g140__g141` (`plan`), the call state `PRE_first_tail_x15_r0_body.s1351`, the merged state `PRE_first_tail_x15_r0_body.s1352`,
the site template `PRE_first_tail_x15_r0_body.st140` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1353`: the merge.
The footprint's facts are in `SiteF140`, the compaction's in `SiteC140`, `SiteK140`, `SiteNa140`, `SiteNb140`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso140 : PRE_first_tail_x15_r0_body.st140.s0 = { PRE_first_tail_x15_r0_body.s1351 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs140 : List Frame := PRE_first_tail_x15_r0_body.s1351.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_140 : PRE_first_tail_x15_r0_body.S1351.tab.length = 6040
kernel_rfl PRE_first_tail_x15_r0_body.tab0_140 : PRE_first_tail_x15_r0_body.st140.S0.tab = PRE_first_tail_x15_r0_body.S1351.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws140 : List Nat := [3354, 3355, 3356, 3357, 3358, 3359, 3360, 3361, 3362]
kernel_rfl PRE_first_tail_x15_r0_body.fresh140 : (PRE_first_tail_x15_r0_body.S1351.tab.all fun e => PRE_first_tail_x15_r0_body.ws140.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1351.oracle.all fun q => PRE_first_tail_x15_r0_body.ws140.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab140 : PRE_first_tail_x15_r0_body.S1352.tab = PRE_first_tail_x15_r0_body.S1351.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws140
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen140 : PRE_first_tail_x15_r0_body.st140.S2.tab.length - PRE_first_tail_x15_r0_body.st140.S0.tab.length = 9

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged140`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap140 : PRE_first_tail_x15_r0_body.s1352.heap = PRE_first_tail_x15_r0_body.st140.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext140 : PRE_first_tail_x15_r0_body.s1352.next = PRE_first_tail_x15_r0_body.st140.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl140 : PRE_first_tail_x15_r0_body.s1352.ctl = PRE_first_tail_x15_r0_body.st140.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack140 : PRE_first_tail_x15_r0_body.s1352.stack = PRE_first_tail_x15_r0_body.st140.s2.stack ++ PRE_first_tail_x15_r0_body.s1351.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs140 : PRE_first_tail_x15_r0_body.s1352.jobs = PRE_first_tail_x15_r0_body.st140.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi140 : PRE_first_tail_x15_r0_body.s1352.ffi = PRE_first_tail_x15_r0_body.st140.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace140 : PRE_first_tail_x15_r0_body.s1352.trace = PRE_first_tail_x15_r0_body.st140.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores140 : PRE_first_tail_x15_r0_body.s1352.stores = PRE_first_tail_x15_r0_body.st140.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 140 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived140 : PRE_first_tail_x15_r0_body.nr140.map (fun r => nth? PRE_first_tail_x15_r0_body.st140.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo140 : PRE_first_tail_x15_r0_body.nr140.all (Nat.ble 6040) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj140 : PRE_first_tail_x15_r0_body.cws140.all (fun c => !PRE_first_tail_x15_r0_body.ws140.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ140 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws140 PRE_first_tail_x15_r0_body.crs140 PRE_first_tail_x15_r0_body.ws140

end Host.Load.Run.Tpl
end

section -- st140/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st140`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st140.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st140.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st140.s2.heap PRE_first_tail_x15_r0_body.st140.wrR ++ freshOf PRE_first_tail_x15_r0_body.st140.s2.heap PRE_first_tail_x15_r0_body.st140.s0.next PRE_first_tail_x15_r0_body.st140.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st140.wr : List Nat := PRE_first_tail_x15_r0_body.st140.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st140.heapFoot : PRE_first_tail_x15_r0_body.st140.s2.heap = setAll PRE_first_tail_x15_r0_body.st140.s0.heap PRE_first_tail_x15_r0_body.st140.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st140.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st140.s0.next PRE_first_tail_x15_r0_body.st140.s2.next = true
theorem PRE_first_tail_x15_r0_body.st140.grows : PRE_first_tail_x15_r0_body.st140.s0.next ≤ PRE_first_tail_x15_r0_body.st140.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st140.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st140.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st140.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st140.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st140.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st140.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st140.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st140.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st140.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st140.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st140.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st140.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 140 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB140 : nodupT PRE_first_tail_x15_r0_body.st140.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup140 : PRE_first_tail_x15_r0_body.st140.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB140).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB140 : PRE_first_tail_x15_r0_body.st140.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound140 : ∀ b ∈ PRE_first_tail_x15_r0_body.st140.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB140 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr140 := PRE_first_tail_x15_r0_body.st140.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq140 : PRE_first_tail_x15_r0_body.st140.s2.trace = PRE_first_tail_x15_r0_body.trFr140 ++ PRE_first_tail_x15_r0_body.st140.s0.trace
theorem PRE_first_tail_x15_r0_body.trace140 : ∃ fr, PRE_first_tail_x15_r0_body.st140.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st140.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq140⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide140 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB140 : (PRE_first_tail_x15_r0_body.wide140.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st140.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix140 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide140, WFix Map.id (Present PRE_first_tail_x15_r0_body.st140.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB140 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 140 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1352`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO140 : PRE_first_tail_x15_r0_body.st140.S0.oracle = PRE_first_tail_x15_r0_body.st140.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B140 : PRE_first_tail_x15_r0_body.st140.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st140.s0.next || (PRE_first_tail_x15_r0_body.st140.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot140 : Conv.StageFoot PRE_first_tail_x15_r0_body.st140.wr PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st140.heapFoot PRE_first_tail_x15_r0_body.wrNodup140 PRE_first_tail_x15_r0_body.wrBound140 PRE_first_tail_x15_r0_body.wr0B140 PRE_first_tail_x15_r0_body.st140.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged140 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st140.F.S → PRE_first_tail_x15_r0_body.st140.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st140.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st140.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs140 PRE_first_tail_x15_r0_body.st140.wr PRE_first_tail_x15_r0_body.s1351 PRE_first_tail_x15_r0_body.st140.s2 PRE_first_tail_x15_r0_body.st140.s0
      PRE_first_tail_x15_r0_body.st140.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st140.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1352 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso140 PRE_first_tail_x15_r0_body.stFoot140 PRE_first_tail_x15_r0_body.wrNodup140 PRE_first_tail_x15_r0_body.wrBound140 PRE_first_tail_x15_r0_body.trace140 PRE_first_tail_x15_r0_body.mheap140
    PRE_first_tail_x15_r0_body.mnext140 PRE_first_tail_x15_r0_body.mctl140 PRE_first_tail_x15_r0_body.mstack140 PRE_first_tail_x15_r0_body.mjobs140 PRE_first_tail_x15_r0_body.mffi140 PRE_first_tail_x15_r0_body.mtrace140 PRE_first_tail_x15_r0_body.mstores140 h

def PRE_first_tail_x15_r0_body.arrEl140_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE140_2665 : arrOf PRE_first_tail_x15_r0_body.s1352 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl140_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA140_2665 : isArrB PRE_first_tail_x15_r0_body.s1352 2665 = true
theorem PRE_first_tail_x15_r0_body.arr140_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1352.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl140_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE140_2665 PRE_first_tail_x15_r0_body.arrA140_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN140_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl140_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR140_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl140_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN140_2665

def PRE_first_tail_x15_r0_body.arrEl140_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE140_2673467 : arrOf PRE_first_tail_x15_r0_body.s1352 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl140_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA140_2673467 : isArrB PRE_first_tail_x15_r0_body.s1352 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr140_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1352.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl140_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE140_2673467 PRE_first_tail_x15_r0_body.arrA140_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN140_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl140_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR140_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl140_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN140_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k140 : isArrB PRE_first_tail_x15_r0_body.s1352 4910 = false
theorem PRE_first_tail_x15_r0_body.keep140 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1352 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k140 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr140_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl140_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ140
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 140 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1351`, the merged
state `PRE_first_tail_x15_r0_body.s1352`, the canonical state `PRE_first_tail_x15_r0_body.s1353`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl140 : PRE_first_tail_x15_r0_body.pl140.all (Nat.ble PRE_first_tail_x15_r0_body.s1351.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd140 : nodupT PRE_first_tail_x15_r0_body.pl140 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1140 : Nat.ble PRE_first_tail_x15_r0_body.s1351.next 2784355 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst140 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1351.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn140 : PRE_first_tail_x15_r0_body.s1353.next = PRE_first_tail_x15_r0_body.s1351.next + PRE_first_tail_x15_r0_body.pl140.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn140 : PRE_first_tail_x15_r0_body.s1352.next = 2784355
kernel_rfl PRE_first_tail_x15_r0_body.zgrow140 : Nat.ble PRE_first_tail_x15_r0_body.s1353.next PRE_first_tail_x15_r0_body.s1352.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh140 : PRE_first_tail_x15_r0_body.S1351.tab.all (fun e => PRE_first_tail_x15_r0_body.cws140.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd140 : nodupT PRE_first_tail_x15_r0_body.cws140 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi140 : PRE_first_tail_x15_r0_body.nr140.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1352.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt140 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1351.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg140_2665 : PRE_first_tail_x15_r0_body.s1353.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1353 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk140_2665 : (objOf PRE_first_tail_x15_r0_body.s1353 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm140_2665 : PRE_first_tail_x15_r0_body.s1352.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa140.obj (objOf PRE_first_tail_x15_r0_body.s1353 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1352 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg140_2673467 : PRE_first_tail_x15_r0_body.s1353.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1353 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk140_2673467 : (objOf PRE_first_tail_x15_r0_body.s1353 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm140_2673467 : PRE_first_tail_x15_r0_body.s1352.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa140.obj (objOf PRE_first_tail_x15_r0_body.s1353 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1352 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw140_4910 : (PRE_first_tail_x15_r0_body.s1353.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw140_2673472 : (PRE_first_tail_x15_r0_body.s1353.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw140_2673473 : (PRE_first_tail_x15_r0_body.s1353.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd140 : PRE_first_tail_x15_r0_body.cl140.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr140 : PRE_first_tail_x15_r0_body.st140.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1351.next || PRE_first_tail_x15_r0_body.cl140.contains b) = true
def PRE_first_tail_x15_r0_body.zl140 : List Nat := PRE_first_tail_x15_r0_body.cl140.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE140 : PRE_first_tail_x15_r0_body.zl140.map (fun a => PRE_first_tail_x15_r0_body.s1352.heap.get (PRE_first_tail_x15_r0_body.kappa140.a a)) = PRE_first_tail_x15_r0_body.zl140.map (fun a => (PRE_first_tail_x15_r0_body.s1353.heap.get a).map PRE_first_tail_x15_r0_body.kappa140.hobj)
theorem PRE_first_tail_x15_r0_body.zimg140 : HeapImg PRE_first_tail_x15_r0_body.kappa140 PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.s1352 PRE_first_tail_x15_r0_body.zl140 := PRE_first_tail_x15_r0_body.zimgE140
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl140 : PRE_first_tail_x15_r0_body.s1352.ctl = PRE_first_tail_x15_r0_body.kappa140.ctl PRE_first_tail_x15_r0_body.s1353.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack140 : PRE_first_tail_x15_r0_body.s1352.stack = PRE_first_tail_x15_r0_body.s1353.stack.map PRE_first_tail_x15_r0_body.kappa140.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs140 : PRE_first_tail_x15_r0_body.s1352.jobs = PRE_first_tail_x15_r0_body.s1353.jobs.map PRE_first_tail_x15_r0_body.kappa140.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores140 : PRE_first_tail_x15_r0_body.s1352.stores = PRE_first_tail_x15_r0_body.kappa140.stores PRE_first_tail_x15_r0_body.s1353.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots140 : checkRootsSupp PRE_first_tail_x15_r0_body.s1353 6040 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC140 : PRE_first_tail_x15_r0_body.S1351.tab.length + PRE_first_tail_x15_r0_body.cws140.length = 6040
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap140 : PRE_first_tail_x15_r0_body.kappa140 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1351.next 2784355 PRE_first_tail_x15_r0_body.S1351.tab.length PRE_first_tail_x15_r0_body.pl140 (PRE_first_tail_x15_r0_body.nr140.map NumV.ref) PRE_first_tail_x15_r0_body.kd140.big
  PRE_first_tail_x15_r0_body.kd140.region PRE_first_tail_x15_r0_body.kd140.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin140 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1353.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc140 : Conv.jcleanListB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.cl140 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB140 : noBigRootsP (fun i => !Conv.oldBigB (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1353.trace PRE_first_tail_x15_r0_body.s1353 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm140 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18055 = true
theorem PRE_first_tail_x15_r0_body.cjcl140 (h : Conv.JClean (⟨20949, 18055, 2784335, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1351) : Conv.JClean (⟨20949, 18055, 2784336, 6040⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1353 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle140)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap140 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd140 a ha)) PRE_first_tail_x15_r0_body.zjc140

end Host.Load.Run.Tpl
end

section -- st140/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st140.bodyLast from PRE_first_tail_x15_r0_body.st140.s1 to PRE_first_tail_x15_r0_body.st140.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st140.F PRE_first_tail_x15_r0_body.st140.s1).run PRE_first_tail_x15_r0_body.st140.S1 = some (PRE_first_tail_x15_r0_body.st140.s2, PRE_first_tail_x15_r0_body.st140.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st140.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st140.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st140.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st140.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st140/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st140.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st140.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st140.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st140.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st140.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st140.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st140.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st140.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st140.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st140.s1 PRE_first_tail_x15_r0_body.st140.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st140/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st140.bodyK0F from PRE_first_tail_x15_r0_body.st140.s0 to PRE_first_tail_x15_r0_body.st140.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st140.F (PRE_first_tail_x15_r0_body.st140.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st140.ks 0).getD 0) PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st140.s1, PRE_first_tail_x15_r0_body.st140.S1)
theorem PRE_first_tail_x15_r0_body.st140.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st140.F (PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st140.ks 0).getD 0) PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st140.s1, PRE_first_tail_x15_r0_body.st140.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st140.bodyOkLN_ok PRE_first_tail_x15_r0_body.st140.bodyK0F
end Host.Load.Run.Tpl
end

section -- st140/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st140.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st140.F (PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows) 206 PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.S0 = some (PRE_first_tail_x15_r0_body.st140.s1, PRE_first_tail_x15_r0_body.st140.S1) :=
  (congrFun (congrFun PRE_first_tail_x15_r0_body.st140.bodyK0 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st140.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st140.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st140.F (PRE_first_tail_x15_r0_body.st140.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st140.s0
  S0 := PRE_first_tail_x15_r0_body.st140.S0
  s1 := PRE_first_tail_x15_r0_body.st140.s1
  S1 := PRE_first_tail_x15_r0_body.st140.S1
  s2 := PRE_first_tail_x15_r0_body.st140.s2
  S2 := PRE_first_tail_x15_r0_body.st140.S2
  n := 206
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st140.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st140.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st140.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st140.bodyHalt
  last := PRE_first_tail_x15_r0_body.st140.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st140.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 141 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1369` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa141` into the merged state
`PRE_first_tail_x15_r0_body.s1368`. -/

def PRE_first_tail_x15_r0_body.pl141 : List Nat := [2786438, 2786274, 2786326, 2786439, 2786440, 2786276, 2786328, 2786437, 2786436, 2786435, 2786434, 2786428, 2786379, 2786430, 2786381]
def PRE_first_tail_x15_r0_body.nr141 : List Nat := [6125, 6126, 6122, 6128, 6124, 6132, 6133, 6130, 6131]
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd141 : RData :=
  ⟨2786091, 2786441, Stage.setAll PTrie.nil [(2786076, 2786438), (2786077, 2786274), (2786078, 2786326), (2786079, 2786439), (2786080, 2786440), (2786081, 2786276), (2786082, 2786328), (2786083, 2786437), (2786084, 2786436), (2786085, 2786435), (2786086, 2786434), (2786087, 2786428), (2786088, 2786379), (2786089, 2786430), (2786090, 2786381)], Stage.setAll PTrie.nil [(20989, 20991), (20990, 20992), (20991, 20994), (20992, 20993)],
   20993, 20995, 18089, 18089, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil [(6117, .ref 6125), (6118, .ref 6126), (6119, .ref 6122), (6120, .ref 6128), (6121, .ref 6124), (6122, .ref 6132), (6123, .ref 6133), (6124, .ref 6130), (6125, .ref 6131)]⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa141 : Map :=
  Conv.Map.compact 2786076 2786441 6117 PRE_first_tail_x15_r0_body.pl141 (PRE_first_tail_x15_r0_body.nr141.map NumV.ref) PRE_first_tail_x15_r0_body.kd141.big
    PRE_first_tail_x15_r0_body.kd141.region PRE_first_tail_x15_r0_body.kd141.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws141 : List Nat := [3380, 3381, 3382, 3383, 3384, 3385, 3386, 3387, 3388]
noncomputable def PRE_first_tail_x15_r0_body.crs141 : List SymE := PRE_first_tail_x15_r0_body.nr141.map fun r => (nth? PRE_first_tail_x15_r0_body.S1368.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta141 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws141 PRE_first_tail_x15_r0_body.crs141
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB141 : List Nat := [2665, 2672663, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab141 : PRE_first_tail_x15_r0_body.S1369.tab = PRE_first_tail_x15_r0_body.S1367.tab ++ PRE_first_tail_x15_r0_body.cws141.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace141 : PRE_first_tail_x15_r0_body.s1369.trace = PRE_first_tail_x15_r0_body.s1367.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext141 : PRE_first_tail_x15_r0_body.s1369.next = 2786091
kernel_rfl PRE_first_tail_x15_r0_body.ccounters141 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.nnext) = (20993, 18089)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1368.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa141.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.tokens.all (bSN 6126) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean141 : Conv.cleanListB 20993 131072 (fun r => Nat.ble 83972 r) PRE_first_tail_x15_r0_body.s1369
    (PRE_first_tail_x15_r0_body.wrB141 ++ (List.range 15).map (2786076 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs141 : bigsOutB 20993 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl141`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl141 : List Nat := [2665, 2672663, 2673467, 2786076, 2786077, 2786078, 2786079, 2786080, 2786081, 2786082, 2786083, 2786084, 2786085, 2786086, 2786087, 2786088, 2786089, 2786090]
def PRE_first_tail_x15_r0_body.clo141 : List Nat := [20989, 20990, 20991, 20992]
def PRE_first_tail_x15_r0_body.cln141 : List Nat := [18083, 18084, 18085, 18086, 18087, 18088]
def PRE_first_tail_x15_r0_body.cli141 : List Nat := [18083, 18084, 18085, 18086, 18087, 18088]
kernel_rfl PRE_first_tail_x15_r0_body.cheap141 : PRE_first_tail_x15_r0_body.s1369.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1367.heap (PRE_first_tail_x15_r0_body.cl141.filterMap fun a => (PRE_first_tail_x15_r0_body.s1369.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe141 : Nat.ble PRE_first_tail_x15_r0_body.s1367.next PRE_first_tail_x15_r0_body.s1369.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP141 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp141 : Conv.suppListB PRE_first_tail_x15_r0_body.s1369 6126 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound141 : Conv.boundListB PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst141 : Conv.sstListB 6126 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx PRE_first_tail_x15_r0_body.cln141 PRE_first_tail_x15_r0_body.clo141 PRE_first_tail_x15_r0_body.cli141 = true

end Host.Load.Run.Tpl
end

section -- SiteCl141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA141 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd141 : (PRE_first_tail_x15_r0_body.clo141 ++ PRE_first_tail_x15_r0_body.cln141 ++ PRE_first_tail_x15_r0_body.cli141).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle141 : Conv.Cnt.leB (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck141 : Conv.ncleanListB (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx PRE_first_tail_x15_r0_body.clo141 PRE_first_tail_x15_r0_body.cln141 PRE_first_tail_x15_r0_body.cli141 = true
theorem PRE_first_tail_x15_r0_body.cncl141 (h : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) : Conv.NClean (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle141 PRE_first_tail_x15_r0_body.ckA141 PRE_first_tail_x15_r0_body.cobjsK141 PRE_first_tail_x15_r0_body.cnodesK141 PRE_first_tail_x15_r0_body.citemsK141 PRE_first_tail_x15_r0_body.cbd141 PRE_first_tail_x15_r0_body.cck141

end Host.Load.Run.Tpl
end

section -- SiteS141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 141 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc141 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P141 : LoadP := PRE_first_tail_x15_r0_body.Pc141.raise 18089
kernel_rfl PRE_first_tail_x15_r0_body.craise141 : Nat.ble PRE_first_tail_x15_r0_body.Pc141.N0 18089 = true
theorem PRE_first_tail_x15_r0_body.raised141 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc141 PRE_first_tail_x15_r0_body.P141 :=
  .inr ⟨18089, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise141, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_141 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_141 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1368.ffi)
def PRE_first_tail_x15_r0_body.khinv141 : PTrie Nat := Stage.setAll PTrie.nil [(20991, 20989), (20992, 20990), (20994, 20991), (20993, 20992)]
def PRE_first_tail_x15_r0_body.kninv141 : PTrie Nat := Stage.setAll PTrie.nil [(18083, 18083), (18084, 18084), (18085, 18085), (18086, 18086), (18087, 18087), (18088, 18088)]
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS141 : List Nat := [20989, 20990, 20991, 20992, 20993, 20994]
def PRE_first_tail_x15_r0_body.cnS141 : List Nat := List.range' 18083 6
def PRE_first_tail_x15_r0_body.ciS141 : List Nat := [] ++ List.range' 18083 6

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0141 : PRE_first_tail_x15_r0_body.kd141.nh0 = PRE_first_tail_x15_r0_body.cx0_141.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1141 : PRE_first_tail_x15_r0_body.kd141.nh1 = PRE_first_tail_x15_r0_body.cx1_141.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0141 : PRE_first_tail_x15_r0_body.kd141.nn0 = PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1141 : PRE_first_tail_x15_r0_body.kd141.nn1 = PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo141 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P141.lo && Nat.ble PRE_first_tail_x15_r0_body.P141.lo PRE_first_tail_x15_r0_body.cx0_141.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P141.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P141.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt141 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_141.mlx.next PRE_first_tail_x15_r0_body.cx1_141.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband141 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P141.NL && Nat.ble PRE_first_tail_x15_r0_body.P141.NL PRE_first_tail_x15_r0_body.P141.N0 && Nat.ble PRE_first_tail_x15_r0_body.P141.N0 PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow141 : PRE_first_tail_x15_r0_body.kd141.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren141 : checkRenG PRE_first_tail_x15_r0_body.kd141.hnd PRE_first_tail_x15_r0_body.khinv141 (phB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband141 : PRE_first_tail_x15_r0_body.kd141.checkBand PRE_first_tail_x15_r0_body.P141.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos141 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd141.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren141 : checkRenG PRE_first_tail_x15_r0_body.kd141.node PRE_first_tail_x15_r0_body.kninv141 (pnB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P141.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd141.nodeF j) PRE_first_tail_x15_r0_body.cx1_141.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a141 : PRE_first_tail_x15_r0_body.cx0_141.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b141 : PRE_first_tail_x15_r0_body.cx0_141.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.pending = PRE_first_tail_x15_r0_body.cx0_141.mlx.pending.map PRE_first_tail_x15_r0_body.kappa141.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.errh = PRE_first_tail_x15_r0_body.cx0_141.mlx.errh.map PRE_first_tail_x15_r0_body.kappa141.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.files = PRE_first_tail_x15_r0_body.cx0_141.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.arch = PRE_first_tail_x15_r0_body.cx0_141.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_141.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.wired = PRE_first_tail_x15_r0_body.cx0_141.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost141 : PRE_first_tail_x15_r0_body.cx1_141.host = PRE_first_tail_x15_r0_body.cx0_141.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd141`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0141 : PRE_first_tail_x15_r0_body.kd141.n0 = 2786091
kernel_rfl PRE_first_tail_x15_r0_body.ckn1141 : PRE_first_tail_x15_r0_body.kd141.n1 = 2786441
kernel_rfl PRE_first_tail_x15_r0_body.ckheap141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.heap).all (fun x => Nat.ble 2786076 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl141 : (List.range 15).all (fun j => decide (PRE_first_tail_x15_r0_body.kd141.heap.get (2786076 + j) = nth? PRE_first_tail_x15_r0_body.pl141 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja141 : Nat.ble 2786076 2786076 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn141 : Nat.ble 6117 6117 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD141 : Nat.ble 2786076 PRE_first_tail_x15_r0_body.kd141.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn141 : Nat.ble 20989 PRE_first_tail_x15_r0_body.kd141.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn141 : Nat.ble 18083 PRE_first_tail_x15_r0_body.kd141.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb141 : Nat.ble 20989 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.heap).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.hnd).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (Nat.ble (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix141 : Conv.FixOld (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa141 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn141) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb141) PRE_first_tail_x15_r0_body.fheap141 PRE_first_tail_x15_r0_body.fhnd141 PRE_first_tail_x15_r0_body.fnode141
kernel_rfl PRE_first_tail_x15_r0_body.fcxn141 : (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn141 : (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0141 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_141.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_141.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I141 : PRE_first_tail_x15_r0_body.cx1_141.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS141.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd141 : (PRE_first_tail_x15_r0_body.clo141 ++ PRE_first_tail_x15_r0_body.cln141 ++ PRE_first_tail_x15_r0_body.cli141 ++ PRE_first_tail_x15_r0_body.cwS141 ++ PRE_first_tail_x15_r0_body.cnS141 ++ PRE_first_tail_x15_r0_body.ciS141).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW141 : PRE_first_tail_x15_r0_body.cwS141.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo141.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI141 : PRE_first_tail_x15_r0_body.ciS141.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli141.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN141 : PRE_first_tail_x15_r0_body.cnS141.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF141 : PRE_first_tail_x15_r0_body.cln141.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh141 : PRE_first_tail_x15_r0_body.clo141.all (handleOK PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141.lo PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo141 : PRE_first_tail_x15_r0_body.clo141.map (fun h => PRE_first_tail_x15_r0_body.cx1_141.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa141.handle h)) = PRE_first_tail_x15_r0_body.clo141.map (fun h => (PRE_first_tail_x15_r0_body.cx0_141.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa141.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok141 : PRE_first_tail_x15_r0_body.clo141.all (objOK PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141.NL PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd141 : PRE_first_tail_x15_r0_body.cln141.all (nodeOKF PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.P141 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp141 : ((PRE_first_tail_x15_r0_body.cln141.filter (fullB PRE_first_tail_x15_r0_body.P141))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_141.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa141.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln141.filter (fullB PRE_first_tail_x15_r0_body.P141))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_141.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa141.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI141 : incrB PRE_first_tail_x15_r0_body.kd141.nodeF (List.range' 18083 6) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK141 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all (fun k => Nat.ble 18083 k && Nat.blt k 18089) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL141 : (PRE_first_tail_x15_r0_body.cln141.filter (Nat.ble PRE_first_tail_x15_r0_body.P141.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd141.nodeF i) && (Nat.blt i 18089 || Nat.ble PRE_first_tail_x15_r0_body.kd141.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord141 : (PRE_first_tail_x15_r0_body.cln141.filter (Nat.ble PRE_first_tail_x15_r0_body.P141.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd141.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd141.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd141.nodeF j) (PRE_first_tail_x15_r0_body.kd141.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow141 PRE_first_tail_x15_r0_body.cnn1141 PRE_first_tail_x15_r0_body.fnordI141 PRE_first_tail_x15_r0_body.fnordK141 PRE_first_tail_x15_r0_body.fnordL141
kernel_rfl PRE_first_tail_x15_r0_body.fi141 : PRE_first_tail_x15_r0_body.cli141.all (pnB PRE_first_tail_x15_r0_body.cx0_141.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii141 : PRE_first_tail_x15_r0_body.cli141.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_141.mlx.items.get (PRE_first_tail_x15_r0_body.kappa141.node k) = (PRE_first_tail_x15_r0_body.cx0_141.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa141.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.kd141 PRE_first_tail_x15_r0_body.khinv141 PRE_first_tail_x15_r0_body.kninv141 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.cx1_141.mlx (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo141 PRE_first_tail_x15_r0_body.cln141 PRE_first_tail_x15_r0_body.cli141 PRE_first_tail_x15_r0_body.cwS141 PRE_first_tail_x15_r0_body.cnS141 PRE_first_tail_x15_r0_body.ciS141 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0141, PRE_first_tail_x15_r0_body.cnh1141, PRE_first_tail_x15_r0_body.cnn0141, PRE_first_tail_x15_r0_body.cnn1141, PRE_first_tail_x15_r0_body.cplo141, PRE_first_tail_x15_r0_body.ccnt141, PRE_first_tail_x15_r0_body.cnband141, PRE_first_tail_x15_r0_body.chbelow141, PRE_first_tail_x15_r0_body.chren141, PRE_first_tail_x15_r0_body.cband141, PRE_first_tail_x15_r0_body.cnh1pos141, PRE_first_tail_x15_r0_body.cnren141, PRE_first_tail_x15_r0_body.cnlow141, PRE_first_tail_x15_r0_body.cabs0a141, PRE_first_tail_x15_r0_body.cabs0b141, PRE_first_tail_x15_r0_body.ctok1141, PRE_first_tail_x15_r0_body.cpend141, PRE_first_tail_x15_r0_body.cerrh141, PRE_first_tail_x15_r0_body.cfiles141, PRE_first_tail_x15_r0_body.carch141, PRE_first_tail_x15_r0_body.csizes141, PRE_first_tail_x15_r0_body.cwired141, PRE_first_tail_x15_r0_body.cfix141, clean, PRE_first_tail_x15_r0_body.fcxn141, PRE_first_tail_x15_r0_body.fcnn141, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0141, PRE_first_tail_x15_r0_body.fnk141, PRE_first_tail_x15_r0_body.ckA141, PRE_first_tail_x15_r0_body.cobjsK141, PRE_first_tail_x15_r0_body.cnodesK141, PRE_first_tail_x15_r0_body.citemsK141, PRE_first_tail_x15_r0_body.f1A141, PRE_first_tail_x15_r0_body.f1O141, PRE_first_tail_x15_r0_body.f1N141, PRE_first_tail_x15_r0_body.f1I141, PRE_first_tail_x15_r0_body.fbd141, PRE_first_tail_x15_r0_body.fincW141, PRE_first_tail_x15_r0_body.fincI141, PRE_first_tail_x15_r0_body.fincN141, PRE_first_tail_x15_r0_body.flnF141, PRE_first_tail_x15_r0_body.fh141, PRE_first_tail_x15_r0_body.fo141, PRE_first_tail_x15_r0_body.fok141, PRE_first_tail_x15_r0_body.fnd141, PRE_first_tail_x15_r0_body.fp141, PRE_first_tail_x15_r0_body.fnord141, PRE_first_tail_x15_r0_body.fi141, PRE_first_tail_x15_r0_body.fii141⟩
theorem PRE_first_tail_x15_r0_body.cnshift141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx) : NShift PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.cx0_141 PRE_first_tail_x15_r0_body.cx1_141 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost141 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0141 PRE_first_tail_x15_r0_body.ckn1141 PRE_first_tail_x15_r0_body.ckheap141 PRE_first_tail_x15_r0_body.ckpl141)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1367.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1367.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1367.ffi) = some PRE_first_tail_x15_r0_body.fxC_141
kernel_rfl PRE_first_tail_x15_r0_body.okrC_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1367.ffi) = some PRE_first_tail_x15_r0_body.krC_141
noncomputable def PRE_first_tail_x15_r0_body.fx0_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1369.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1369.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1369.ffi) = some PRE_first_tail_x15_r0_body.fx0_141
kernel_rfl PRE_first_tail_x15_r0_body.okr0_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1369.ffi) = some PRE_first_tail_x15_r0_body.kr0_141
noncomputable def PRE_first_tail_x15_r0_body.fx1_141 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1368.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_141 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1368.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_141 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1368.ffi) = some PRE_first_tail_x15_r0_body.fx1_141
kernel_rfl PRE_first_tail_x15_r0_body.okr1_141 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1368.ffi) = some PRE_first_tail_x15_r0_body.kr1_141
kernel_rfl PRE_first_tail_x15_r0_body.ff0141 : PRE_first_tail_x15_r0_body.fx0_141 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_141 (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_141.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1141 : PRE_first_tail_x15_r0_body.fx1_141 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_141 (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_141.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck141 : freedLB PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.fx0_141 PRE_first_tail_x15_r0_body.fx1_141 PRE_first_tail_x15_r0_body.clo141 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0141 : PRE_first_tail_x15_r0_body.kr0_141.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.flags (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_141.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0141 : PRE_first_tail_x15_r0_body.kr0_141.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.targs (PRE_first_tail_x15_r0_body.clo141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_141.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1141 : PRE_first_tail_x15_r0_body.kr1_141.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.flags (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_141.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1141 : PRE_first_tail_x15_r0_body.kr1_141.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_141.targs (PRE_first_tail_x15_r0_body.cwS141.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_141.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck141 : krecLB PRE_first_tail_x15_r0_body.kappa141 6126 PRE_first_tail_x15_r0_body.cx0_141.mlx PRE_first_tail_x15_r0_body.kr0_141 PRE_first_tail_x15_r0_body.kr1_141 PRE_first_tail_x15_r0_body.clo141 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn141 : Nat.ble 6117 6126 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge141 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1368.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1369.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR141 : pendRegB PRE_first_tail_x15_r0_body.kappa141 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe141 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1369.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1368.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift141 (clean : Conv.NClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P141.NL) (cl : SSt (· < 6126) PRE_first_tail_x15_r0_body.cx0_141.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_141.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_141.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_141.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1367.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_141.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P141 6126 PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369.ffi PRE_first_tail_x15_r0_body.s1368.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift141 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue141, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp141 t ht),
    PRE_first_tail_x15_r0_body.cbridge141,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1369.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1368.ffi) (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_141 PRE_first_tail_x15_r0_body.ofx1_141 hobjC PRE_first_tail_x15_r0_body.ff0141 PRE_first_tail_x15_r0_body.ff1141 PRE_first_tail_x15_r0_body.ffck141,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1369.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1368.ffi) (PRE_first_tail_x15_r0_body.cfoot141 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_141 PRE_first_tail_x15_r0_body.okr1_141 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn141) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0141 PRE_first_tail_x15_r0_body.fkt0141 PRE_first_tail_x15_r0_body.fkf1141 PRE_first_tail_x15_r0_body.fkt1141 PRE_first_tail_x15_r0_body.fkck141,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0141 PRE_first_tail_x15_r0_body.cnh1141 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe141) PRE_first_tail_x15_r0_body.cpendR141⟩

end Host.Load.Run.Tpl
end

section -- st141/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st141 0
host_stream_state PRE_first_tail_x15_r0_body.st141 1
host_stream_state PRE_first_tail_x15_r0_body.st141 2
host_stream_state PRE_first_tail_x15_r0_body.st141 3
end Host.Load.Run.Tpl
end

section -- Site141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 141 of chain `PRE_first_tail_x15_r0_body`: `kvW__g141__g142` (`appendWindow`), the call state `PRE_first_tail_x15_r0_body.s1367`, the merged state `PRE_first_tail_x15_r0_body.s1368`,
the site template `PRE_first_tail_x15_r0_body.st141` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1369`: the merge.
The footprint's facts are in `SiteF141`, the compaction's in `SiteC141`, `SiteK141`, `SiteNa141`, `SiteNb141`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso141 : PRE_first_tail_x15_r0_body.st141.s0 = { PRE_first_tail_x15_r0_body.s1367 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs141 : List Frame := PRE_first_tail_x15_r0_body.s1367.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_141 : PRE_first_tail_x15_r0_body.S1367.tab.length = 6117
kernel_rfl PRE_first_tail_x15_r0_body.tab0_141 : PRE_first_tail_x15_r0_body.st141.S0.tab = PRE_first_tail_x15_r0_body.S1367.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws141 : List Nat := [3363, 3364, 3365, 3366, 3367, 3368, 3369, 3370, 3371, 3372, 3373, 3374, 3375, 3376, 3377, 3378, 3379]
kernel_rfl PRE_first_tail_x15_r0_body.fresh141 : (PRE_first_tail_x15_r0_body.S1367.tab.all fun e => PRE_first_tail_x15_r0_body.ws141.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1367.oracle.all fun q => PRE_first_tail_x15_r0_body.ws141.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab141 : PRE_first_tail_x15_r0_body.S1368.tab = PRE_first_tail_x15_r0_body.S1367.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws141
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen141 : PRE_first_tail_x15_r0_body.st141.S3.tab.length - PRE_first_tail_x15_r0_body.st141.S0.tab.length = 17

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged141`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap141 : PRE_first_tail_x15_r0_body.s1368.heap = PRE_first_tail_x15_r0_body.st141.s3.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext141 : PRE_first_tail_x15_r0_body.s1368.next = PRE_first_tail_x15_r0_body.st141.s3.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl141 : PRE_first_tail_x15_r0_body.s1368.ctl = PRE_first_tail_x15_r0_body.st141.s3.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack141 : PRE_first_tail_x15_r0_body.s1368.stack = PRE_first_tail_x15_r0_body.st141.s3.stack ++ PRE_first_tail_x15_r0_body.s1367.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs141 : PRE_first_tail_x15_r0_body.s1368.jobs = PRE_first_tail_x15_r0_body.st141.s3.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi141 : PRE_first_tail_x15_r0_body.s1368.ffi = PRE_first_tail_x15_r0_body.st141.s3.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace141 : PRE_first_tail_x15_r0_body.s1368.trace = PRE_first_tail_x15_r0_body.st141.s3.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores141 : PRE_first_tail_x15_r0_body.s1368.stores = PRE_first_tail_x15_r0_body.st141.s3.stores

end Host.Load.Run.Tpl
end

section -- SiteD141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 141 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived141 : PRE_first_tail_x15_r0_body.nr141.map (fun r => nth? PRE_first_tail_x15_r0_body.st141.S3.tab r) =
  [some (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.un .int32 (SymE.bin .mul (SymE.un .floor (SymE.bin .div (SymE.bin .sub (SymE.bin .add (SymE.lit (F64.fin false 256 (0))) (SymE.un .int32 (SymE.un .int32 (SymE.var 10)))) (SymE.lit (F64.fin false 1 (0)))) (SymE.lit (F64.fin false 256 (0))))) (SymE.lit (F64.fin false 256 (0))))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false))),
   some (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))),
   some (SymE.bin .sub (SymE.un .int32 (SymE.bin .add (SymE.lit (F64.zero false)) (SymE.un .int32 (SymE.un .int32 (SymE.var 10))))) (SymE.lit (F64.zero false)))]
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo141 : PRE_first_tail_x15_r0_body.nr141.all (Nat.ble 6117) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj141 : PRE_first_tail_x15_r0_body.cws141.all (fun c => !PRE_first_tail_x15_r0_body.ws141.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ141 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws141 PRE_first_tail_x15_r0_body.crs141 PRE_first_tail_x15_r0_body.ws141

end Host.Load.Run.Tpl
end

section -- st141/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st141`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st141.wrR : List (Nat × Nat) := [(2672663, 2672664)]
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st141.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st141.s3.heap PRE_first_tail_x15_r0_body.st141.wrR ++ freshOf PRE_first_tail_x15_r0_body.st141.s3.heap PRE_first_tail_x15_r0_body.st141.s0.next PRE_first_tail_x15_r0_body.st141.s3.next
noncomputable def PRE_first_tail_x15_r0_body.st141.wr : List Nat := PRE_first_tail_x15_r0_body.st141.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st141.heapFoot : PRE_first_tail_x15_r0_body.st141.s3.heap = setAll PRE_first_tail_x15_r0_body.st141.s0.heap PRE_first_tail_x15_r0_body.st141.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st141.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st141.s0.next PRE_first_tail_x15_r0_body.st141.s3.next = true
theorem PRE_first_tail_x15_r0_body.st141.grows : PRE_first_tail_x15_r0_body.st141.s0.next ≤ PRE_first_tail_x15_r0_body.st141.s3.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st141.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st141.wh : List Nat := [20989, 20990, 20991, 20992, 20993, 20994]
def PRE_first_tail_x15_r0_body.st141.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st141.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st141.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st141.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st141.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st141.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st141.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st141.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st141.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st141.s3.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 141 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB141 : nodupT PRE_first_tail_x15_r0_body.st141.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup141 : PRE_first_tail_x15_r0_body.st141.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB141).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB141 : PRE_first_tail_x15_r0_body.st141.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound141 : ∀ b ∈ PRE_first_tail_x15_r0_body.st141.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB141 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr141 := PRE_first_tail_x15_r0_body.st141.s3.trace.take 26
kernel_rfl PRE_first_tail_x15_r0_body.traceEq141 : PRE_first_tail_x15_r0_body.st141.s3.trace = PRE_first_tail_x15_r0_body.trFr141 ++ PRE_first_tail_x15_r0_body.st141.s0.trace
theorem PRE_first_tail_x15_r0_body.trace141 : ∃ fr, PRE_first_tail_x15_r0_body.st141.s3.trace = fr ++ PRE_first_tail_x15_r0_body.st141.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq141⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide141 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB141 : (PRE_first_tail_x15_r0_body.wide141.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st141.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix141 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide141, WFix Map.id (Present PRE_first_tail_x15_r0_body.st141.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB141 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 141 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1368`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO141 : PRE_first_tail_x15_r0_body.st141.S0.oracle = PRE_first_tail_x15_r0_body.st141.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B141 : PRE_first_tail_x15_r0_body.st141.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st141.s0.next || (PRE_first_tail_x15_r0_body.st141.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot141 : Conv.StageFoot PRE_first_tail_x15_r0_body.st141.wr PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.s3 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st141.heapFoot PRE_first_tail_x15_r0_body.wrNodup141 PRE_first_tail_x15_r0_body.wrBound141 PRE_first_tail_x15_r0_body.wr0B141 PRE_first_tail_x15_r0_body.st141.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged141 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st141.F.S → PRE_first_tail_x15_r0_body.st141.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st141.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st141.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs141 PRE_first_tail_x15_r0_body.st141.wr PRE_first_tail_x15_r0_body.s1367 PRE_first_tail_x15_r0_body.st141.s3 PRE_first_tail_x15_r0_body.st141.s0
      PRE_first_tail_x15_r0_body.st141.s3.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st141.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1368 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso141 PRE_first_tail_x15_r0_body.stFoot141 PRE_first_tail_x15_r0_body.wrNodup141 PRE_first_tail_x15_r0_body.wrBound141 PRE_first_tail_x15_r0_body.trace141 PRE_first_tail_x15_r0_body.mheap141
    PRE_first_tail_x15_r0_body.mnext141 PRE_first_tail_x15_r0_body.mctl141 PRE_first_tail_x15_r0_body.mstack141 PRE_first_tail_x15_r0_body.mjobs141 PRE_first_tail_x15_r0_body.mffi141 PRE_first_tail_x15_r0_body.mtrace141 PRE_first_tail_x15_r0_body.mstores141 h

def PRE_first_tail_x15_r0_body.arrEl141_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE141_2665 : arrOf PRE_first_tail_x15_r0_body.s1368 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl141_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA141_2665 : isArrB PRE_first_tail_x15_r0_body.s1368 2665 = true
theorem PRE_first_tail_x15_r0_body.arr141_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1368.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl141_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE141_2665 PRE_first_tail_x15_r0_body.arrA141_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN141_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl141_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR141_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl141_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN141_2665

def PRE_first_tail_x15_r0_body.arrEl141_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE141_2673467 : arrOf PRE_first_tail_x15_r0_body.s1368 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl141_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA141_2673467 : isArrB PRE_first_tail_x15_r0_body.s1368 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr141_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1368.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl141_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE141_2673467 PRE_first_tail_x15_r0_body.arrA141_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN141_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl141_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR141_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl141_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN141_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k141 : isArrB PRE_first_tail_x15_r0_body.s1368 4910 = false
theorem PRE_first_tail_x15_r0_body.keep141 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1368 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k141 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr141_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl141_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ141
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 141 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1367`, the merged
state `PRE_first_tail_x15_r0_body.s1368`, the canonical state `PRE_first_tail_x15_r0_body.s1369`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl141 : PRE_first_tail_x15_r0_body.pl141.all (Nat.ble PRE_first_tail_x15_r0_body.s1367.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd141 : nodupT PRE_first_tail_x15_r0_body.pl141 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1141 : Nat.ble PRE_first_tail_x15_r0_body.s1367.next 2786441 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst141 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1367.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn141 : PRE_first_tail_x15_r0_body.s1369.next = PRE_first_tail_x15_r0_body.s1367.next + PRE_first_tail_x15_r0_body.pl141.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn141 : PRE_first_tail_x15_r0_body.s1368.next = 2786441
kernel_rfl PRE_first_tail_x15_r0_body.zgrow141 : Nat.ble PRE_first_tail_x15_r0_body.s1369.next PRE_first_tail_x15_r0_body.s1368.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh141 : PRE_first_tail_x15_r0_body.S1367.tab.all (fun e => PRE_first_tail_x15_r0_body.cws141.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd141 : nodupT PRE_first_tail_x15_r0_body.cws141 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi141 : PRE_first_tail_x15_r0_body.nr141.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1368.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt141 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1367.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg141_2665 : PRE_first_tail_x15_r0_body.s1369.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1369 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk141_2665 : (objOf PRE_first_tail_x15_r0_body.s1369 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm141_2665 : PRE_first_tail_x15_r0_body.s1368.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa141.obj (objOf PRE_first_tail_x15_r0_body.s1369 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1368 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg141_2673467 : PRE_first_tail_x15_r0_body.s1369.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1369 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk141_2673467 : (objOf PRE_first_tail_x15_r0_body.s1369 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm141_2673467 : PRE_first_tail_x15_r0_body.s1368.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa141.obj (objOf PRE_first_tail_x15_r0_body.s1369 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1368 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw141_4910 : (PRE_first_tail_x15_r0_body.s1369.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw141_2673472 : (PRE_first_tail_x15_r0_body.s1369.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw141_2673473 : (PRE_first_tail_x15_r0_body.s1369.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd141 : PRE_first_tail_x15_r0_body.cl141.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr141 : PRE_first_tail_x15_r0_body.st141.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1367.next || PRE_first_tail_x15_r0_body.cl141.contains b) = true
def PRE_first_tail_x15_r0_body.zl141 : List Nat := PRE_first_tail_x15_r0_body.cl141.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE141 : PRE_first_tail_x15_r0_body.zl141.map (fun a => PRE_first_tail_x15_r0_body.s1368.heap.get (PRE_first_tail_x15_r0_body.kappa141.a a)) = PRE_first_tail_x15_r0_body.zl141.map (fun a => (PRE_first_tail_x15_r0_body.s1369.heap.get a).map PRE_first_tail_x15_r0_body.kappa141.hobj)
theorem PRE_first_tail_x15_r0_body.zimg141 : HeapImg PRE_first_tail_x15_r0_body.kappa141 PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.s1368 PRE_first_tail_x15_r0_body.zl141 := PRE_first_tail_x15_r0_body.zimgE141
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl141 : PRE_first_tail_x15_r0_body.s1368.ctl = PRE_first_tail_x15_r0_body.kappa141.ctl PRE_first_tail_x15_r0_body.s1369.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack141 : PRE_first_tail_x15_r0_body.s1368.stack = PRE_first_tail_x15_r0_body.s1369.stack.map PRE_first_tail_x15_r0_body.kappa141.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs141 : PRE_first_tail_x15_r0_body.s1368.jobs = PRE_first_tail_x15_r0_body.s1369.jobs.map PRE_first_tail_x15_r0_body.kappa141.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores141 : PRE_first_tail_x15_r0_body.s1368.stores = PRE_first_tail_x15_r0_body.kappa141.stores PRE_first_tail_x15_r0_body.s1369.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots141 : checkRootsSupp PRE_first_tail_x15_r0_body.s1369 6126 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC141 : PRE_first_tail_x15_r0_body.S1367.tab.length + PRE_first_tail_x15_r0_body.cws141.length = 6126
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap141 : PRE_first_tail_x15_r0_body.kappa141 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1367.next 2786441 PRE_first_tail_x15_r0_body.S1367.tab.length PRE_first_tail_x15_r0_body.pl141 (PRE_first_tail_x15_r0_body.nr141.map NumV.ref) PRE_first_tail_x15_r0_body.kd141.big
  PRE_first_tail_x15_r0_body.kd141.region PRE_first_tail_x15_r0_body.kd141.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin141 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1369.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc141 : Conv.jcleanListB (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1369 PRE_first_tail_x15_r0_body.cl141 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB141 : noBigRootsP (fun i => !Conv.oldBigB (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1369.trace PRE_first_tail_x15_r0_body.s1369 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm141 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18083 = true
theorem PRE_first_tail_x15_r0_body.cjcl141 (h : Conv.JClean (⟨20989, 18083, 2786076, 6117⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1367) : Conv.JClean (⟨20993, 18089, 2786091, 6126⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1369 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle141)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap141 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd141 a ha)) PRE_first_tail_x15_r0_body.zjc141

end Host.Load.Run.Tpl
end

section -- st141/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st141.bodyLast from PRE_first_tail_x15_r0_body.st141.s2 to PRE_first_tail_x15_r0_body.st141.s3 :
  interpS (step PRE_first_tail_x15_r0_body.st141.F PRE_first_tail_x15_r0_body.st141.s2).run PRE_first_tail_x15_r0_body.st141.S2 = some (PRE_first_tail_x15_r0_body.st141.s3, PRE_first_tail_x15_r0_body.st141.S3)
kernel_rfl PRE_first_tail_x15_r0_body.st141.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st141.s2.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st141.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st141.s3.stack = true

end Host.Load.Run.Tpl
end

section -- st141/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st141.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st141.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st141.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st141.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st141.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st141.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st141.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st141.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st141.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st141.s2 PRE_first_tail_x15_r0_body.st141.S2) = fun _ _ => true

end Host.Load.Run.Tpl
end

section -- st141/TypedK0
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st141.bodyK0F from PRE_first_tail_x15_r0_body.st141.s0 to PRE_first_tail_x15_r0_body.st141.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st141.ks 0).getD 0) PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st141.s1, PRE_first_tail_x15_r0_body.st141.S1)
theorem PRE_first_tail_x15_r0_body.st141.bodyK0 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st141.ks 0).getD 0) PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st141.s1, PRE_first_tail_x15_r0_body.st141.S1) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st141.bodyOkLN_ok PRE_first_tail_x15_r0_body.st141.bodyK0F
end Host.Load.Run.Tpl
end

section -- st141/TypedK1
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st141.bodyK1F from PRE_first_tail_x15_r0_body.st141.s1 to PRE_first_tail_x15_r0_body.st141.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st141.ks 1).getD 0) PRE_first_tail_x15_r0_body.st141.s1 PRE_first_tail_x15_r0_body.st141.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st141.s2, PRE_first_tail_x15_r0_body.st141.S2)
theorem PRE_first_tail_x15_r0_body.st141.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st141.ks 1).getD 0) PRE_first_tail_x15_r0_body.st141.s1 PRE_first_tail_x15_r0_body.st141.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st141.s2, PRE_first_tail_x15_r0_body.st141.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st141.bodyOkLN_ok PRE_first_tail_x15_r0_body.st141.bodyK1F
end Host.Load.Run.Tpl
end

section -- st141/TypedTpl
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

theorem PRE_first_tail_x15_r0_body.st141.bodyRun (bytes : List Byte) (rows : Nat) :
    runOk PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows) 3452 PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.S0 = some (PRE_first_tail_x15_r0_body.st141.s2, PRE_first_tail_x15_r0_body.st141.S2) :=
  runOk_trans PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows) ((nth? PRE_first_tail_x15_r0_body.st141.ks 0).getD 0) ((nth? PRE_first_tail_x15_r0_body.st141.ks 1).getD 0) PRE_first_tail_x15_r0_body.st141.s0 PRE_first_tail_x15_r0_body.st141.s1 PRE_first_tail_x15_r0_body.st141.s2 PRE_first_tail_x15_r0_body.st141.S0 PRE_first_tail_x15_r0_body.st141.S1 PRE_first_tail_x15_r0_body.st141.S2 ((congrFun (congrFun PRE_first_tail_x15_r0_body.st141.bodyK0 bytes) rows)) (congrFun (congrFun PRE_first_tail_x15_r0_body.st141.bodyK1 bytes) rows)

theorem PRE_first_tail_x15_r0_body.st141.bodyLocal (bytes : List Byte) (rows : Nat) : ∀ s S, PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows s S = true → Disp.localB s = true := okLocal_localB

noncomputable def PRE_first_tail_x15_r0_body.st141.bodyTpl (bytes : List Byte) (rows : Nat) : Host.Ts.Sim.Stage.StageTpl PRE_first_tail_x15_r0_body.st141.F (PRE_first_tail_x15_r0_body.st141.bodyOkL bytes rows) where
  s0 := PRE_first_tail_x15_r0_body.st141.s0
  S0 := PRE_first_tail_x15_r0_body.st141.S0
  s1 := PRE_first_tail_x15_r0_body.st141.s2
  S1 := PRE_first_tail_x15_r0_body.st141.S2
  s2 := PRE_first_tail_x15_r0_body.st141.s3
  S2 := PRE_first_tail_x15_r0_body.st141.S3
  n := 3452
  ok0 := congrFun (congrFun PRE_first_tail_x15_r0_body.st141.bodyAccepted0 bytes) rows
  run := PRE_first_tail_x15_r0_body.st141.bodyRun bytes rows
  ok1 := congrFun (congrFun PRE_first_tail_x15_r0_body.st141.bodyAccepted1 bytes) rows
  halt := PRE_first_tail_x15_r0_body.st141.bodyHalt
  last := PRE_first_tail_x15_r0_body.st141.bodyLast
  top := noBlockTop_sound PRE_first_tail_x15_r0_body.st141.bodyTopCheck
end Host.Load.Run.Tpl
end

section -- SiteC142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction after the merge at call site 142 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact`, `Conv.full_compactQ`): the canonical
state `PRE_first_tail_x15_r0_body.s1377` (the stage's results at canonical places, its trace the call's) under `PRE_first_tail_x15_r0_body.kappa142` into the merged state
`PRE_first_tail_x15_r0_body.s1376`. -/

def PRE_first_tail_x15_r0_body.pl142 : List Nat := []
def PRE_first_tail_x15_r0_body.nr142 : List Nat := []
/-- The native part of the compaction map (canonical → merged handles and nodes: its `big`, `region`, `nodeF`). -/
def PRE_first_tail_x15_r0_body.kd142 : RData :=
  ⟨2786673, 2786675, Stage.setAll PTrie.nil [], Stage.setAll PTrie.nil [],
   21006, 21006, 18099, 18099, Stage.setAll PTrie.nil [],
   Stage.setAll PTrie.nil []⟩
/-- **The compaction map.** -/
noncomputable def PRE_first_tail_x15_r0_body.kappa142 : Map :=
  Conv.Map.compact 2786673 2786675 6149 PRE_first_tail_x15_r0_body.pl142 (PRE_first_tail_x15_r0_body.nr142.map NumV.ref) PRE_first_tail_x15_r0_body.kd142.big
    PRE_first_tail_x15_r0_body.kd142.region PRE_first_tail_x15_r0_body.kd142.nodeF
/-- The canonical result variables and their images, the merged state's entries (`Conv.compactθ`). -/
def PRE_first_tail_x15_r0_body.cws142 : List Nat := []
noncomputable def PRE_first_tail_x15_r0_body.crs142 : List SymE := PRE_first_tail_x15_r0_body.nr142.map fun r => (nth? PRE_first_tail_x15_r0_body.S1376.tab r).getD (.var 0)
noncomputable def PRE_first_tail_x15_r0_body.ctheta142 : Nat → SymE := Conv.compactθ PRE_first_tail_x15_r0_body.cws142 PRE_first_tail_x15_r0_body.crs142
/-- The call's entries the stage wrote (renamed in the canonical state with the results). -/
def PRE_first_tail_x15_r0_body.wrB142 : List Nat := [2665, 2673467]

kernel_rfl PRE_first_tail_x15_r0_body.ctab142 : PRE_first_tail_x15_r0_body.S1377.tab = PRE_first_tail_x15_r0_body.S1375.tab ++ PRE_first_tail_x15_r0_body.cws142.map SymE.var
kernel_rfl PRE_first_tail_x15_r0_body.ctrace142 : PRE_first_tail_x15_r0_body.s1377.trace = PRE_first_tail_x15_r0_body.s1375.trace
kernel_rfl PRE_first_tail_x15_r0_body.cnext142 : PRE_first_tail_x15_r0_body.s1377.next = 2786673
kernel_rfl PRE_first_tail_x15_r0_body.ccounters142 : ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.next, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.nnext) = (21006, 18099)
-- the merged state's readback queue, carried to the canonical state (`Conv.FullShiftQ.tokens`, `tokSupp`)
kernel_rfl PRE_first_tail_x15_r0_body.cqueue142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1376.ffi).mlx.tokens = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.tokens.map PRE_first_tail_x15_r0_body.kappa142.nv
kernel_rfl PRE_first_tail_x15_r0_body.ctokSupp142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.tokens.all (bSN 6149) = true
-- the written and the result entries carry no bigint of the canonical fresh band [next, E) and no fresh region
kernel_rfl PRE_first_tail_x15_r0_body.cclean142 : Conv.cleanListB 21006 131072 (fun r => Nat.ble 84024 r) PRE_first_tail_x15_r0_body.s1377
    (PRE_first_tail_x15_r0_body.wrB142 ++ (List.range 0).map (2786673 + ·)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cbigs142 : bigsOutB 21006 131072 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx = true

end Host.Load.Run.Tpl
end

section -- SiteK142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical state's closedness from the call's (`Conv.closed_of_callB`, `Conv.sst_of_callB`): it keeps the call's entries
off the written and the result ones (`PRE_first_tail_x15_r0_body.cl142`; natively the written and result handles, the result nodes, the written
and result items), and those are checked. -/

def PRE_first_tail_x15_r0_body.cl142 : List Nat := [2665, 2673467]
def PRE_first_tail_x15_r0_body.clo142 : List Nat := []
def PRE_first_tail_x15_r0_body.cln142 : List Nat := []
def PRE_first_tail_x15_r0_body.cli142 : List Nat := []
kernel_rfl PRE_first_tail_x15_r0_body.cheap142 : PRE_first_tail_x15_r0_body.s1377.heap = Stage.setAll PRE_first_tail_x15_r0_body.s1375.heap (PRE_first_tail_x15_r0_body.cl142.filterMap fun a => (PRE_first_tail_x15_r0_body.s1377.heap.get a).map (a, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cnextLe142 : Nat.ble PRE_first_tail_x15_r0_body.s1375.next PRE_first_tail_x15_r0_body.s1377.next = true
kernel_rfl PRE_first_tail_x15_r0_body.ckeepP142 : Conv.keptPresentB PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.csupp142 : Conv.suppListB PRE_first_tail_x15_r0_body.s1377 6149 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.cbound142 : Conv.boundListB PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnodesK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cln142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cobjsK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.citemsK142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.items (PRE_first_tail_x15_r0_body.cli142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.csst142 : Conv.sstListB 6149 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cli142 = true

end Host.Load.Run.Tpl
end

section -- SiteCl142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl PRE_first_tail_x15_r0_body.ckA142 : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.cbd142 : (PRE_first_tail_x15_r0_body.clo142 ++ PRE_first_tail_x15_r0_body.cln142 ++ PRE_first_tail_x15_r0_body.cli142).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.cle142 : Conv.Cnt.leB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) = true
kernel_rfl PRE_first_tail_x15_r0_body.cck142 : Conv.ncleanListB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.cli142 = true
theorem PRE_first_tail_x15_r0_body.cncl142 (h : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx) : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx :=
  Conv.NClean.stepKeep h PRE_first_tail_x15_r0_body.cle142 PRE_first_tail_x15_r0_body.ckA142 PRE_first_tail_x15_r0_body.cobjsK142 PRE_first_tail_x15_r0_body.cnodesK142 PRE_first_tail_x15_r0_body.citemsK142 PRE_first_tail_x15_r0_body.cbd142 PRE_first_tail_x15_r0_body.cck142

end Host.Load.Run.Tpl
end

section -- SiteS142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's native shift at call site 142 from its footprint (`Conv.nshift_of_foot`), and the observers'
(`liveShift_foot`, `kernShift_foot`): `Conv.FullShiftQ` for `Conv.full_compactQ`, given the call's bookkeeping and its
relation's facts. -/

/-- The load parameters of the chain (band-free: its start's node counter as `NL` and `N0`). -/
def PRE_first_tail_x15_r0_body.Pc142 : LoadP := ⟨18151, 131072, 1099511627776, 15235, 15235, []⟩
/-- The site's band raised to the map's checked fixed-node prefix, including newly recorded closure traces. -/
def PRE_first_tail_x15_r0_body.P142 : LoadP := PRE_first_tail_x15_r0_body.Pc142.raise 18099
kernel_rfl PRE_first_tail_x15_r0_body.craise142 : Nat.ble PRE_first_tail_x15_r0_body.Pc142.N0 18099 = true
theorem PRE_first_tail_x15_r0_body.raised142 : Host.Ts.Sim.Full.Raised PRE_first_tail_x15_r0_body.Pc142 PRE_first_tail_x15_r0_body.P142 :=
  .inr ⟨18099, rfl, Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.craise142, rfl⟩
noncomputable abbrev PRE_first_tail_x15_r0_body.cx0_142 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi)
noncomputable abbrev PRE_first_tail_x15_r0_body.cx1_142 : Host.Load.LSt := clearTokens (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1376.ffi)
def PRE_first_tail_x15_r0_body.khinv142 : PTrie Nat := Stage.setAll PTrie.nil []
def PRE_first_tail_x15_r0_body.kninv142 : PTrie Nat := Stage.setAll PTrie.nil []
/-- The stage's footprint: its written and fresh handles, fresh nodes, written and fresh items. -/
def PRE_first_tail_x15_r0_body.cwS142 : List Nat := []
def PRE_first_tail_x15_r0_body.cnS142 : List Nat := List.range' 18099 0
def PRE_first_tail_x15_r0_body.ciS142 : List Nat := [] ++ List.range' 18099 0

-- the small checks (`MChecks`'s)
kernel_rfl PRE_first_tail_x15_r0_body.cnh0142 : PRE_first_tail_x15_r0_body.kd142.nh0 = PRE_first_tail_x15_r0_body.cx0_142.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnh1142 : PRE_first_tail_x15_r0_body.kd142.nh1 = PRE_first_tail_x15_r0_body.cx1_142.mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.cnn0142 : PRE_first_tail_x15_r0_body.kd142.nn0 = PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cnn1142 : PRE_first_tail_x15_r0_body.kd142.nn1 = PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.cplo142 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P142.lo && Nat.ble PRE_first_tail_x15_r0_body.P142.lo PRE_first_tail_x15_r0_body.cx0_142.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.P142.lo RData.bigHi && Nat.ble RData.bigHi PRE_first_tail_x15_r0_body.P142.E) = true
kernel_rfl PRE_first_tail_x15_r0_body.ccnt142 : (Nat.ble PRE_first_tail_x15_r0_body.cx0_142.mlx.next PRE_first_tail_x15_r0_body.cx1_142.mlx.next && Nat.ble PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnband142 : (Nat.blt 0 PRE_first_tail_x15_r0_body.P142.NL && Nat.ble PRE_first_tail_x15_r0_body.P142.NL PRE_first_tail_x15_r0_body.P142.N0 && Nat.ble PRE_first_tail_x15_r0_body.P142.N0 PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.chbelow142 : PRE_first_tail_x15_r0_body.kd142.checkHndBelow = true
kernel_rfl PRE_first_tail_x15_r0_body.chren142 : checkRenG PRE_first_tail_x15_r0_body.kd142.hnd PRE_first_tail_x15_r0_body.khinv142 (phB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cband142 : PRE_first_tail_x15_r0_body.kd142.checkBand PRE_first_tail_x15_r0_body.P142.lo = true
kernel_rfl PRE_first_tail_x15_r0_body.cnh1pos142 : Nat.blt 0 PRE_first_tail_x15_r0_body.kd142.nh1 = true
kernel_rfl PRE_first_tail_x15_r0_body.cnren142 : checkRenG PRE_first_tail_x15_r0_body.kd142.node PRE_first_tail_x15_r0_body.kninv142 (pnB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.cnlow142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (fun j => Nat.ble PRE_first_tail_x15_r0_body.P142.NL j && Nat.blt (PRE_first_tail_x15_r0_body.kd142.nodeF j) PRE_first_tail_x15_r0_body.cx1_142.mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.cabs0a142 : PRE_first_tail_x15_r0_body.cx0_142.mlx.arrs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.cabs0b142 : PRE_first_tail_x15_r0_body.cx0_142.mlx.objs.get 0 = none
kernel_rfl PRE_first_tail_x15_r0_body.ctok1142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.tokens = []
kernel_rfl PRE_first_tail_x15_r0_body.cpend142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.pending = PRE_first_tail_x15_r0_body.cx0_142.mlx.pending.map PRE_first_tail_x15_r0_body.kappa142.pend
kernel_rfl PRE_first_tail_x15_r0_body.cerrh142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.errh = PRE_first_tail_x15_r0_body.cx0_142.mlx.errh.map PRE_first_tail_x15_r0_body.kappa142.arg
kernel_rfl PRE_first_tail_x15_r0_body.cfiles142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.files = PRE_first_tail_x15_r0_body.cx0_142.mlx.files
kernel_rfl PRE_first_tail_x15_r0_body.carch142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.arch = PRE_first_tail_x15_r0_body.cx0_142.mlx.arch
kernel_rfl PRE_first_tail_x15_r0_body.csizes142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.deviceSizes = PRE_first_tail_x15_r0_body.cx0_142.mlx.deviceSizes
kernel_rfl PRE_first_tail_x15_r0_body.cwired142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.wired = PRE_first_tail_x15_r0_body.cx0_142.mlx.wired
kernel_rfl PRE_first_tail_x15_r0_body.chost142 : PRE_first_tail_x15_r0_body.cx1_142.host = PRE_first_tail_x15_r0_body.cx0_142.host
-- the compaction map's addresses are `PRE_first_tail_x15_r0_body.kd142`'s
kernel_rfl PRE_first_tail_x15_r0_body.ckn0142 : PRE_first_tail_x15_r0_body.kd142.n0 = 2786673
kernel_rfl PRE_first_tail_x15_r0_body.ckn1142 : PRE_first_tail_x15_r0_body.kd142.n1 = 2786675
kernel_rfl PRE_first_tail_x15_r0_body.ckheap142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.heap).all (fun x => Nat.ble 2786673 x) = true
kernel_rfl PRE_first_tail_x15_r0_body.ckpl142 : (List.range 0).all (fun j => decide (PRE_first_tail_x15_r0_body.kd142.heap.get (2786673 + j) = nth? PRE_first_tail_x15_r0_body.pl142 j)) = true
-- the map fixes the call's names (`Conv.fixOld_compact`), the call's counters
kernel_rfl PRE_first_tail_x15_r0_body.fja142 : Nat.ble 2786673 2786673 = true
kernel_rfl PRE_first_tail_x15_r0_body.fn142 : Nat.ble 6149 6149 = true
kernel_rfl PRE_first_tail_x15_r0_body.fjaD142 : Nat.ble 2786673 PRE_first_tail_x15_r0_body.kd142.n0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxn142 : Nat.ble 21006 PRE_first_tail_x15_r0_body.kd142.nh0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fnn142 : Nat.ble 18099 PRE_first_tail_x15_r0_body.kd142.nn0 = true
kernel_rfl PRE_first_tail_x15_r0_body.fxb142 : Nat.ble 21006 RData.bigHi = true
kernel_rfl PRE_first_tail_x15_r0_body.fheap142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.heap).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).ja) = true
kernel_rfl PRE_first_tail_x15_r0_body.fhnd142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.hnd).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).xn) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnode142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (Nat.ble (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).nn) = true
/-- The compaction map fixes the call's names. -/
theorem PRE_first_tail_x15_r0_body.cfix142 : Conv.FixOld (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.kappa142 :=
  Conv.fixOld_compact (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fja142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fjaD142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fnn142) (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fxb142) PRE_first_tail_x15_r0_body.fheap142 PRE_first_tail_x15_r0_body.fhnd142 PRE_first_tail_x15_r0_body.fnode142
kernel_rfl PRE_first_tail_x15_r0_body.fcxn142 : (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).xn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next
kernel_rfl PRE_first_tail_x15_r0_body.fcnn142 : (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).nn = (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext
kernel_rfl PRE_first_tail_x15_r0_body.fle0142 : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next PRE_first_tail_x15_r0_body.cx0_142.mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext PRE_first_tail_x15_r0_body.cx0_142.mlx.nnext && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next RData.bigHi) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnk142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) = true
-- the merged state keeps the call's entries off the stage's footprint
kernel_rfl PRE_first_tail_x15_r0_body.f1A142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.arrs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.arrs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1O142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.objs = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.objs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1N142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nodes (PRE_first_tail_x15_r0_body.cnS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.f1I142 : PRE_first_tail_x15_r0_body.cx1_142.mlx.items = Stage.setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.items (PRE_first_tail_x15_r0_body.ciS142.filterMap fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.items.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fbd142 : (PRE_first_tail_x15_r0_body.clo142 ++ PRE_first_tail_x15_r0_body.cln142 ++ PRE_first_tail_x15_r0_body.cli142 ++ PRE_first_tail_x15_r0_body.cwS142 ++ PRE_first_tail_x15_r0_body.cnS142 ++ PRE_first_tail_x15_r0_body.ciS142).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincW142 : PRE_first_tail_x15_r0_body.cwS142.all (fun h => !Nat.blt h (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next || PRE_first_tail_x15_r0_body.clo142.contains h) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincI142 : PRE_first_tail_x15_r0_body.ciS142.all (fun k => !Nat.blt k (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext || PRE_first_tail_x15_r0_body.cli142.contains k) = true
kernel_rfl PRE_first_tail_x15_r0_body.fincN142 : PRE_first_tail_x15_r0_body.cnS142.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) = true
kernel_rfl PRE_first_tail_x15_r0_body.flnF142 : PRE_first_tail_x15_r0_body.cln142.all (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) = true
-- the checks over the changed lists
kernel_rfl PRE_first_tail_x15_r0_body.fh142 : PRE_first_tail_x15_r0_body.clo142.all (handleOK PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142.lo PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fo142 : PRE_first_tail_x15_r0_body.clo142.map (fun h => PRE_first_tail_x15_r0_body.cx1_142.mlx.objs.get (PRE_first_tail_x15_r0_body.kappa142.handle h)) = PRE_first_tail_x15_r0_body.clo142.map (fun h => (PRE_first_tail_x15_r0_body.cx0_142.mlx.objs.get h).map PRE_first_tail_x15_r0_body.kappa142.nobj)
kernel_rfl PRE_first_tail_x15_r0_body.fok142 : PRE_first_tail_x15_r0_body.clo142.all (objOK PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142.NL PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnd142 : PRE_first_tail_x15_r0_body.cln142.all (nodeOKF PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.P142 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fp142 : ((PRE_first_tail_x15_r0_body.cln142.filter (fullB PRE_first_tail_x15_r0_body.P142))).map (fun i => (PRE_first_tail_x15_r0_body.cx1_142.mlx.nodes.get (PRE_first_tail_x15_r0_body.kappa142.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((PRE_first_tail_x15_r0_body.cln142.filter (fullB PRE_first_tail_x15_r0_body.P142))).map (fun i => (PRE_first_tail_x15_r0_body.cx0_142.mlx.nodes.get i).map fun nd => PRE_first_tail_x15_r0_body.kappa142.prim nd.prim)
kernel_rfl PRE_first_tail_x15_r0_body.fnordI142 : incrB PRE_first_tail_x15_r0_body.kd142.nodeF (List.range' 18099 0) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordK142 : (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all (fun k => Nat.ble 18099 k && Nat.blt k 18099) = true
kernel_rfl PRE_first_tail_x15_r0_body.fnordL142 : (PRE_first_tail_x15_r0_body.cln142.filter (Nat.ble PRE_first_tail_x15_r0_body.P142.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd142.nodeF i) && (Nat.blt i 18099 || Nat.ble PRE_first_tail_x15_r0_body.kd142.nn0 i)) = true
theorem PRE_first_tail_x15_r0_body.fnord142 : (PRE_first_tail_x15_r0_body.cln142.filter (Nat.ble PRE_first_tail_x15_r0_body.P142.N0)).all (fun i => Nat.ble i (PRE_first_tail_x15_r0_body.kd142.nodeF i) &&
    (PTrie.keysA PRE_first_tail_x15_r0_body.kd142.node).all fun j => !Nat.blt j i || Nat.blt (PRE_first_tail_x15_r0_body.kd142.nodeF j) (PRE_first_tail_x15_r0_body.kd142.nodeF i)) = true :=
  cnord_of PRE_first_tail_x15_r0_body.cnlow142 PRE_first_tail_x15_r0_body.cnn1142 PRE_first_tail_x15_r0_body.fnordI142 PRE_first_tail_x15_r0_body.fnordK142 PRE_first_tail_x15_r0_body.fnordL142
kernel_rfl PRE_first_tail_x15_r0_body.fi142 : PRE_first_tail_x15_r0_body.cli142.all (pnB PRE_first_tail_x15_r0_body.cx0_142.mlx) = true
kernel_rfl PRE_first_tail_x15_r0_body.fii142 : PRE_first_tail_x15_r0_body.cli142.all (fun k => decide (PRE_first_tail_x15_r0_body.cx1_142.mlx.items.get (PRE_first_tail_x15_r0_body.kappa142.node k) = (PRE_first_tail_x15_r0_body.cx0_142.mlx.items.get k).map PRE_first_tail_x15_r0_body.kappa142.nv)) = true
/-- **The compaction's footprint.** -/
theorem PRE_first_tail_x15_r0_body.cfoot142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx) :
    Conv.MFoot PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.kd142 PRE_first_tail_x15_r0_body.khinv142 PRE_first_tail_x15_r0_body.kninv142 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.cx1_142.mlx (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.clo142 PRE_first_tail_x15_r0_body.cln142 PRE_first_tail_x15_r0_body.cli142 PRE_first_tail_x15_r0_body.cwS142 PRE_first_tail_x15_r0_body.cnS142 PRE_first_tail_x15_r0_body.ciS142 :=
  ⟨rfl, rfl, rfl, PRE_first_tail_x15_r0_body.cnh0142, PRE_first_tail_x15_r0_body.cnh1142, PRE_first_tail_x15_r0_body.cnn0142, PRE_first_tail_x15_r0_body.cnn1142, PRE_first_tail_x15_r0_body.cplo142, PRE_first_tail_x15_r0_body.ccnt142, PRE_first_tail_x15_r0_body.cnband142, PRE_first_tail_x15_r0_body.chbelow142, PRE_first_tail_x15_r0_body.chren142, PRE_first_tail_x15_r0_body.cband142, PRE_first_tail_x15_r0_body.cnh1pos142, PRE_first_tail_x15_r0_body.cnren142, PRE_first_tail_x15_r0_body.cnlow142, PRE_first_tail_x15_r0_body.cabs0a142, PRE_first_tail_x15_r0_body.cabs0b142, PRE_first_tail_x15_r0_body.ctok1142, PRE_first_tail_x15_r0_body.cpend142, PRE_first_tail_x15_r0_body.cerrh142, PRE_first_tail_x15_r0_body.cfiles142, PRE_first_tail_x15_r0_body.carch142, PRE_first_tail_x15_r0_body.csizes142, PRE_first_tail_x15_r0_body.cwired142, PRE_first_tail_x15_r0_body.cfix142, clean, PRE_first_tail_x15_r0_body.fcxn142, PRE_first_tail_x15_r0_body.fcnn142, hltC, nltC, itemsC, tracedC, cl, PRE_first_tail_x15_r0_body.fle0142, PRE_first_tail_x15_r0_body.fnk142, PRE_first_tail_x15_r0_body.ckA142, PRE_first_tail_x15_r0_body.cobjsK142, PRE_first_tail_x15_r0_body.cnodesK142, PRE_first_tail_x15_r0_body.citemsK142, PRE_first_tail_x15_r0_body.f1A142, PRE_first_tail_x15_r0_body.f1O142, PRE_first_tail_x15_r0_body.f1N142, PRE_first_tail_x15_r0_body.f1I142, PRE_first_tail_x15_r0_body.fbd142, PRE_first_tail_x15_r0_body.fincW142, PRE_first_tail_x15_r0_body.fincI142, PRE_first_tail_x15_r0_body.fincN142, PRE_first_tail_x15_r0_body.flnF142, PRE_first_tail_x15_r0_body.fh142, PRE_first_tail_x15_r0_body.fo142, PRE_first_tail_x15_r0_body.fok142, PRE_first_tail_x15_r0_body.fnd142, PRE_first_tail_x15_r0_body.fp142, PRE_first_tail_x15_r0_body.fnord142, PRE_first_tail_x15_r0_body.fi142, PRE_first_tail_x15_r0_body.fii142⟩
theorem PRE_first_tail_x15_r0_body.cnshift142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx) : NShift PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.cx0_142 PRE_first_tail_x15_r0_body.cx1_142 :=
  Conv.nshift_of_foot (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) PRE_first_tail_x15_r0_body.chost142 (compact_a_eq PRE_first_tail_x15_r0_body.ckn0142 PRE_first_tail_x15_r0_body.ckn1142 PRE_first_tail_x15_r0_body.ckheap142 PRE_first_tail_x15_r0_body.ckpl142)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def PRE_first_tail_x15_r0_body.fxC_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1375.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.krC_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1375.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofxC_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1375.ffi) = some PRE_first_tail_x15_r0_body.fxC_142
kernel_rfl PRE_first_tail_x15_r0_body.okrC_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1375.ffi) = some PRE_first_tail_x15_r0_body.krC_142
noncomputable def PRE_first_tail_x15_r0_body.fx0_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1377.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr0_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1377.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx0_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1377.ffi) = some PRE_first_tail_x15_r0_body.fx0_142
kernel_rfl PRE_first_tail_x15_r0_body.okr0_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1377.ffi) = some PRE_first_tail_x15_r0_body.kr0_142
noncomputable def PRE_first_tail_x15_r0_body.fx1_142 : PTrie Unit := (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1376.ffi).getD PTrie.nil
noncomputable def PRE_first_tail_x15_r0_body.kr1_142 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1376.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl PRE_first_tail_x15_r0_body.ofx1_142 : (Host.Ts.Sim.Full.freedOf PRE_first_tail_x15_r0_body.s1376.ffi) = some PRE_first_tail_x15_r0_body.fx1_142
kernel_rfl PRE_first_tail_x15_r0_body.okr1_142 : (Host.Ts.Sim.Full.krecOf PRE_first_tail_x15_r0_body.s1376.ffi) = some PRE_first_tail_x15_r0_body.kr1_142
kernel_rfl PRE_first_tail_x15_r0_body.ff0142 : PRE_first_tail_x15_r0_body.fx0_142 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_142 (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.fx0_142.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ff1142 : PRE_first_tail_x15_r0_body.fx1_142 = Stage.setAll PRE_first_tail_x15_r0_body.fxC_142 (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.fx1_142.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.ffck142 : freedLB PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.fx0_142 PRE_first_tail_x15_r0_body.fx1_142 PRE_first_tail_x15_r0_body.clo142 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkf0142 : PRE_first_tail_x15_r0_body.kr0_142.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.flags (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_142.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt0142 : PRE_first_tail_x15_r0_body.kr0_142.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.targs (PRE_first_tail_x15_r0_body.clo142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr0_142.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkf1142 : PRE_first_tail_x15_r0_body.kr1_142.flags = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.flags (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_142.flags.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkt1142 : PRE_first_tail_x15_r0_body.kr1_142.targs = Stage.setAll PRE_first_tail_x15_r0_body.krC_142.targs (PRE_first_tail_x15_r0_body.cwS142.filterMap fun i => (PRE_first_tail_x15_r0_body.kr1_142.targs.get i).map (i, ·))
kernel_rfl PRE_first_tail_x15_r0_body.fkck142 : krecLB PRE_first_tail_x15_r0_body.kappa142 6149 PRE_first_tail_x15_r0_body.cx0_142.mlx PRE_first_tail_x15_r0_body.kr0_142 PRE_first_tail_x15_r0_body.kr1_142 PRE_first_tail_x15_r0_body.clo142 = true
kernel_rfl PRE_first_tail_x15_r0_body.fkn142 : Nat.ble 6149 6149 = true
-- the bridge and the pending traces' regions
kernel_rfl PRE_first_tail_x15_r0_body.cbridge142 : Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1376.ffi = Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1377.ffi
kernel_rfl PRE_first_tail_x15_r0_body.cpendR142 : pendRegB PRE_first_tail_x15_r0_body.kappa142 (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx = true
kernel_rfl PRE_first_tail_x15_r0_body.cpendLe142 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1377.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1376.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem PRE_first_tail_x15_r0_body.cshift142 (clean : Conv.NClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx h → h < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx i → i < (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < PRE_first_tail_x15_r0_body.P142.NL) (cl : SSt (· < 6149) PRE_first_tail_x15_r0_body.cx0_142.mlx)
    (hobjC : ∀ h, PRE_first_tail_x15_r0_body.fxC_142.get h = some () → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (PRE_first_tail_x15_r0_body.krC_142.flags.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (PRE_first_tail_x15_r0_body.krC_142.targs.get h).isSome = true → ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s1375.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, PRE_first_tail_x15_r0_body.krC_142.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ PRE_first_tail_x15_r0_body.P142 6149 PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1377.ffi PRE_first_tail_x15_r0_body.s1376.ffi :=
  ⟨PRE_first_tail_x15_r0_body.cnshift142 clean hltC nltC itemsC tracedC cl, PRE_first_tail_x15_r0_body.cqueue142, fun t ht => bSN_sound (List.all_eq_true.mp PRE_first_tail_x15_r0_body.ctokSupp142 t ht),
    PRE_first_tail_x15_r0_body.cbridge142,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1377.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1376.ffi) (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.ofx0_142 PRE_first_tail_x15_r0_body.ofx1_142 hobjC PRE_first_tail_x15_r0_body.ff0142 PRE_first_tail_x15_r0_body.ff1142 PRE_first_tail_x15_r0_body.ffck142,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1377.ffi) (x1' := Host.Ts.Sim.Full.mlxOf PRE_first_tail_x15_r0_body.s1376.ffi) (PRE_first_tail_x15_r0_body.cfoot142 clean hltC nltC itemsC tracedC cl) rfl PRE_first_tail_x15_r0_body.okr0_142 PRE_first_tail_x15_r0_body.okr1_142 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.fkn142) hfC htC hclC
      PRE_first_tail_x15_r0_body.fkf0142 PRE_first_tail_x15_r0_body.fkt0142 PRE_first_tail_x15_r0_body.fkf1142 PRE_first_tail_x15_r0_body.fkt1142 PRE_first_tail_x15_r0_body.fkck142,
    pendReg_of rfl PRE_first_tail_x15_r0_body.cnh0142 PRE_first_tail_x15_r0_body.cnh1142 (Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.cpendLe142) PRE_first_tail_x15_r0_body.cpendR142⟩

end Host.Load.Run.Tpl
end

section -- st142/H0
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
host_stream_state PRE_first_tail_x15_r0_body.st142 0
host_stream_state PRE_first_tail_x15_r0_body.st142 1
host_stream_state PRE_first_tail_x15_r0_body.st142 2
end Host.Load.Run.Tpl
end

section -- Site142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 142 of chain `PRE_first_tail_x15_r0_body`: `rowBlocks__g142__g143` (`rowBlocks`), the call state `PRE_first_tail_x15_r0_body.s1375`, the merged state `PRE_first_tail_x15_r0_body.s1376`,
the site template `PRE_first_tail_x15_r0_body.st142` (σ = `Map.id`, θ the identity at its own site), the canonical state `PRE_first_tail_x15_r0_body.s1377`: the merge.
The footprint's facts are in `SiteF142`, the compaction's in `SiteC142`, `SiteK142`, `SiteNa142`, `SiteNb142`. -/

kernel_rfl PRE_first_tail_x15_r0_body.iso142 : PRE_first_tail_x15_r0_body.st142.s0 = { PRE_first_tail_x15_r0_body.s1375 with stack := [] }
/-- The caller's frames at the call. -/
noncomputable def PRE_first_tail_x15_r0_body.rs142 : List Frame := PRE_first_tail_x15_r0_body.s1375.stack
kernel_rfl PRE_first_tail_x15_r0_body.n0_142 : PRE_first_tail_x15_r0_body.S1375.tab.length = 6149
kernel_rfl PRE_first_tail_x15_r0_body.tab0_142 : PRE_first_tail_x15_r0_body.st142.S0.tab = PRE_first_tail_x15_r0_body.S1375.tab

/-- The fresh variables of the stage's results. -/
def PRE_first_tail_x15_r0_body.ws142 : List Nat := [3389, 3390]
kernel_rfl PRE_first_tail_x15_r0_body.fresh142 : (PRE_first_tail_x15_r0_body.S1375.tab.all fun e => PRE_first_tail_x15_r0_body.ws142.all fun v => e.noVar v) &&
    (PRE_first_tail_x15_r0_body.S1375.oracle.all fun q => PRE_first_tail_x15_r0_body.ws142.all fun v => q.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.mergeTab142 : PRE_first_tail_x15_r0_body.S1376.tab = PRE_first_tail_x15_r0_body.S1375.tab ++ Conv.resTab PRE_first_tail_x15_r0_body.ws142
kernel_rfl PRE_first_tail_x15_r0_body.mergeLen142 : PRE_first_tail_x15_r0_body.st142.S2.tab.length - PRE_first_tail_x15_r0_body.st142.S0.tab.length = 2

-- The merged state: the instance's return state with the caller's frames (`PRE_first_tail_x15_r0_body.merged142`, `merged_relB`).
kernel_rfl PRE_first_tail_x15_r0_body.mheap142 : PRE_first_tail_x15_r0_body.s1376.heap = PRE_first_tail_x15_r0_body.st142.s2.heap
kernel_rfl PRE_first_tail_x15_r0_body.mnext142 : PRE_first_tail_x15_r0_body.s1376.next = PRE_first_tail_x15_r0_body.st142.s2.next
kernel_rfl PRE_first_tail_x15_r0_body.mctl142 : PRE_first_tail_x15_r0_body.s1376.ctl = PRE_first_tail_x15_r0_body.st142.s2.ctl
kernel_rfl PRE_first_tail_x15_r0_body.mstack142 : PRE_first_tail_x15_r0_body.s1376.stack = PRE_first_tail_x15_r0_body.st142.s2.stack ++ PRE_first_tail_x15_r0_body.s1375.stack
kernel_rfl PRE_first_tail_x15_r0_body.mjobs142 : PRE_first_tail_x15_r0_body.s1376.jobs = PRE_first_tail_x15_r0_body.st142.s2.jobs
kernel_rfl PRE_first_tail_x15_r0_body.mffi142 : PRE_first_tail_x15_r0_body.s1376.ffi = PRE_first_tail_x15_r0_body.st142.s2.ffi
kernel_rfl PRE_first_tail_x15_r0_body.mtrace142 : PRE_first_tail_x15_r0_body.s1376.trace = PRE_first_tail_x15_r0_body.st142.s2.trace
kernel_rfl PRE_first_tail_x15_r0_body.mstores142 : PRE_first_tail_x15_r0_body.s1376.stores = PRE_first_tail_x15_r0_body.st142.s2.stores

end Host.Load.Run.Tpl
end

section -- SiteD142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The canonical results at call site 142 of chain `PRE_first_tail_x15_r0_body`: their values in the instance's end table, the references past
the call's table, the canonical variables apart from the stage's. -/

kernel_rfl PRE_first_tail_x15_r0_body.cderived142 : PRE_first_tail_x15_r0_body.nr142.map (fun r => nth? PRE_first_tail_x15_r0_body.st142.S2.tab r) =
  []
kernel_rfl PRE_first_tail_x15_r0_body.cnrLo142 : PRE_first_tail_x15_r0_body.nr142.all (Nat.ble 6149) = true
kernel_rfl PRE_first_tail_x15_r0_body.cwsDisj142 : PRE_first_tail_x15_r0_body.cws142.all (fun c => !PRE_first_tail_x15_r0_body.ws142.contains c) = true
/-- The compaction's substitution: the canonical variables to their merged values, the stage's other fresh variables
to `0` (`Conv.compactθZ`). -/
noncomputable def PRE_first_tail_x15_r0_body.cthetaZ142 : Nat → SymE := Conv.compactθZ PRE_first_tail_x15_r0_body.cws142 PRE_first_tail_x15_r0_body.crs142 PRE_first_tail_x15_r0_body.ws142

end Host.Load.Run.Tpl
end

section -- st142/Foot
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `PRE_first_tail_x15_r0_body.st142`'s site template (`Conv.StageFoot`, `Conv.NFoot`): every entry of the return
state other than the written and fresh ones is the start's (kernel evaluation of the equalities). -/

/-- The written heap ranges below the start's counter. -/
def PRE_first_tail_x15_r0_body.st142.wrR : List (Nat × Nat) := []
/-- The written and fresh entries of the return state. -/
noncomputable def PRE_first_tail_x15_r0_body.st142.wrE : List (Nat × Host.Ts.HObj) :=
  rangesOf PRE_first_tail_x15_r0_body.st142.s2.heap PRE_first_tail_x15_r0_body.st142.wrR ++ freshOf PRE_first_tail_x15_r0_body.st142.s2.heap PRE_first_tail_x15_r0_body.st142.s0.next PRE_first_tail_x15_r0_body.st142.s2.next
noncomputable def PRE_first_tail_x15_r0_body.st142.wr : List Nat := PRE_first_tail_x15_r0_body.st142.wrE.map (·.1)

kernel_rfl PRE_first_tail_x15_r0_body.st142.heapFoot : PRE_first_tail_x15_r0_body.st142.s2.heap = setAll PRE_first_tail_x15_r0_body.st142.s0.heap PRE_first_tail_x15_r0_body.st142.wrE
kernel_rfl PRE_first_tail_x15_r0_body.st142.grows_check : Nat.ble PRE_first_tail_x15_r0_body.st142.s0.next PRE_first_tail_x15_r0_body.st142.s2.next = true
theorem PRE_first_tail_x15_r0_body.st142.grows : PRE_first_tail_x15_r0_body.st142.s0.next ≤ PRE_first_tail_x15_r0_body.st142.s2.next := Nat.le_of_ble_eq_true PRE_first_tail_x15_r0_body.st142.grows_check

/-- The written and fresh handles; the written readback items of old nodes. -/
def PRE_first_tail_x15_r0_body.st142.wh : List Nat := []
def PRE_first_tail_x15_r0_body.st142.wi : List Nat := []

kernel_rfl PRE_first_tail_x15_r0_body.st142.arrsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.arrs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.arrs (PRE_first_tail_x15_r0_body.st142.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.arrs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st142.objsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.objs = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.objs (PRE_first_tail_x15_r0_body.st142.wh.filterMap fun h => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.objs.get h).map (h, ·))
kernel_rfl PRE_first_tail_x15_r0_body.st142.nodesFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.nodes = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.nodes (freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.nodes (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st142.itemsFoot : (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.items = setAll (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.items ((PRE_first_tail_x15_r0_body.st142.wi.filterMap fun i => ((Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.items.get i).map (i, ·)) ++
    freshOf (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.items (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.nnext)
kernel_rfl PRE_first_tail_x15_r0_body.st142.counters : (Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.next (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.next && Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s0.ffi).mlx.nnext (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.st142.s2.ffi).mlx.nnext) = true

end Host.Load.Run.Tpl
end

section -- SiteF142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! Call site 142 of chain `PRE_first_tail_x15_r0_body`: `Conv.site_merge`'s footprint facts. -/

kernel_rfl PRE_first_tail_x15_r0_body.wrNodupB142 : nodupT PRE_first_tail_x15_r0_body.st142.wr PTrie.nil = true
theorem PRE_first_tail_x15_r0_body.wrNodup142 : PRE_first_tail_x15_r0_body.st142.wr.Nodup := (nodupT_sound PRE_first_tail_x15_r0_body.wrNodupB142).2
kernel_rfl PRE_first_tail_x15_r0_body.wrBoundB142 : PRE_first_tail_x15_r0_body.st142.wr.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
theorem PRE_first_tail_x15_r0_body.wrBound142 : ∀ b ∈ PRE_first_tail_x15_r0_body.st142.wr, b / 4096 < 4 ^ 31 := fun b hb => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wrBoundB142 b hb)
noncomputable def PRE_first_tail_x15_r0_body.trFr142 := PRE_first_tail_x15_r0_body.st142.s2.trace.take 0
kernel_rfl PRE_first_tail_x15_r0_body.traceEq142 : PRE_first_tail_x15_r0_body.st142.s2.trace = PRE_first_tail_x15_r0_body.trFr142 ++ PRE_first_tail_x15_r0_body.st142.s0.trace
theorem PRE_first_tail_x15_r0_body.trace142 : ∃ fr, PRE_first_tail_x15_r0_body.st142.s2.trace = fr ++ PRE_first_tail_x15_r0_body.st142.s0.trace := ⟨_, PRE_first_tail_x15_r0_body.traceEq142⟩

-- the caller's wide frames at the instance's start (`Conv.isolateW`'s `W0` under `Map.id`) and their `WFix`
def PRE_first_tail_x15_r0_body.wide142 : List (Nat × WFrame) := [(4910, .memo [])]
kernel_rfl PRE_first_tail_x15_r0_body.wfixB142 : (PRE_first_tail_x15_r0_body.wide142.all fun p => wfixB Map.id (presentB PRE_first_tail_x15_r0_body.st142.s0) p.2) = true
theorem PRE_first_tail_x15_r0_body.wfix142 : ∀ p ∈ PRE_first_tail_x15_r0_body.wide142, WFix Map.id (Present PRE_first_tail_x15_r0_body.st142.s0) p.2 :=
  fun p hp => wfix_of (List.all_eq_true.mp PRE_first_tail_x15_r0_body.wfixB142 p hp)

end Host.Load.Run.Tpl
end

section -- SiteL142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The call link's facts at call site 142 of chain `PRE_first_tail_x15_r0_body`: the instance's start server, its footprint (`Conv.StageFoot`), the
merged state `PRE_first_tail_x15_r0_body.s1376`'s framed arrays as the chain start's extended (`arrExt_of`, `numRefs_of`). -/

kernel_rfl PRE_first_tail_x15_r0_body.srvO142 : PRE_first_tail_x15_r0_body.st142.S0.oracle = PRE_first_tail_x15_r0_body.st142.OR
kernel_rfl PRE_first_tail_x15_r0_body.wr0B142 : PRE_first_tail_x15_r0_body.st142.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.st142.s0.next || (PRE_first_tail_x15_r0_body.st142.s0.heap.get b).isSome) = true
theorem PRE_first_tail_x15_r0_body.stFoot142 : Conv.StageFoot PRE_first_tail_x15_r0_body.st142.wr PRE_first_tail_x15_r0_body.st142.s0 PRE_first_tail_x15_r0_body.st142.s2 :=
  stageFoot_of PRE_first_tail_x15_r0_body.st142.heapFoot PRE_first_tail_x15_r0_body.wrNodup142 PRE_first_tail_x15_r0_body.wrBound142 PRE_first_tail_x15_r0_body.wr0B142 PRE_first_tail_x15_r0_body.st142.grows

/-- **The relation at the merged state** from the relation at the merge (`Conv.site_merge`'s; `merged_relB`). -/
theorem PRE_first_tail_x15_r0_body.merged142 {FR : Map → Nat → PRE_first_tail_x15_r0_body.st142.F.S → PRE_first_tail_x15_r0_body.st142.F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Host.Ts.Sim.Ctx} {S : SSrv} {t : St PRE_first_tail_x15_r0_body.st142.F.S} {C : CSrv} {n0 : Nat}
    (h : RelB PRE_first_tail_x15_r0_body.st142.F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) PRE_first_tail_x15_r0_body.rs142 PRE_first_tail_x15_r0_body.st142.wr PRE_first_tail_x15_r0_body.s1375 PRE_first_tail_x15_r0_body.st142.s2 PRE_first_tail_x15_r0_body.st142.s0
      PRE_first_tail_x15_r0_body.st142.s2.ffi) S t C) : RelB PRE_first_tail_x15_r0_body.st142.F FR W stk M ν K PRE_first_tail_x15_r0_body.s1376 S t C :=
  merged_relB PRE_first_tail_x15_r0_body.iso142 PRE_first_tail_x15_r0_body.stFoot142 PRE_first_tail_x15_r0_body.wrNodup142 PRE_first_tail_x15_r0_body.wrBound142 PRE_first_tail_x15_r0_body.trace142 PRE_first_tail_x15_r0_body.mheap142
    PRE_first_tail_x15_r0_body.mnext142 PRE_first_tail_x15_r0_body.mctl142 PRE_first_tail_x15_r0_body.mstack142 PRE_first_tail_x15_r0_body.mjobs142 PRE_first_tail_x15_r0_body.mffi142 PRE_first_tail_x15_r0_body.mtrace142 PRE_first_tail_x15_r0_body.mstores142 h

def PRE_first_tail_x15_r0_body.arrEl142_2665 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE142_2665 : arrOf PRE_first_tail_x15_r0_body.s1376 2665 = arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl142_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrA142_2665 : isArrB PRE_first_tail_x15_r0_body.s1376 2665 = true
theorem PRE_first_tail_x15_r0_body.arr142_2665 : ∃ o, PRE_first_tail_x15_r0_body.s1376.heap.get 2665 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ PRE_first_tail_x15_r0_body.arrEl142_2665) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE142_2665 PRE_first_tail_x15_r0_body.arrA142_2665
kernel_rfl PRE_first_tail_x15_r0_body.arrN142_2665 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl142_2665 = true
theorem PRE_first_tail_x15_r0_body.arrR142_2665 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl142_2665 := numRefs_of PRE_first_tail_x15_r0_body.arrN142_2665

def PRE_first_tail_x15_r0_body.arrEl142_2673467 : List Val := []
kernel_rfl PRE_first_tail_x15_r0_body.arrE142_2673467 : arrOf PRE_first_tail_x15_r0_body.s1376 2673467 = arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl142_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrA142_2673467 : isArrB PRE_first_tail_x15_r0_body.s1376 2673467 = true
theorem PRE_first_tail_x15_r0_body.arr142_2673467 : ∃ o, PRE_first_tail_x15_r0_body.s1376.heap.get 2673467 = some (.obj o) ∧ o.kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ PRE_first_tail_x15_r0_body.arrEl142_2673467) :=
  arrExt_of PRE_first_tail_x15_r0_body.arrE142_2673467 PRE_first_tail_x15_r0_body.arrA142_2673467
kernel_rfl PRE_first_tail_x15_r0_body.arrN142_2673467 : numRefsB PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl142_2673467 = true
theorem PRE_first_tail_x15_r0_body.arrR142_2673467 : Prefill.NumRefs PRE_first_tail_x15_r0_body.S0.tab.length PRE_first_tail_x15_r0_body.arrEl142_2673467 := numRefs_of PRE_first_tail_x15_r0_body.arrN142_2673467

kernel_rfl PRE_first_tail_x15_r0_body.w4910k142 : isArrB PRE_first_tail_x15_r0_body.s1376 4910 = false
theorem PRE_first_tail_x15_r0_body.keep142 (q : List Val) : Host.Ts.Sim.Prefill.KeepsAtW (framesP PRE_first_tail_x15_r0_body.s0 q) PRE_first_tail_x15_r0_body.s1376 := by
  intro a pre pre' hx o es ho hk
  unfold framesP at hx
  simp only at hx
  cases h1 : Nat.beq a 2665
  · cases h2 : Nat.beq a 4910
    · rw [h1, h2] at hx; cases hx
    · have := Nat.eq_of_beq_eq_true h2; subst this
      rw [h1, h2] at hx; cases hx
      exact (notArr_of PRE_first_tail_x15_r0_body.w4910k142 ho hk).elim
  · have := Nat.eq_of_beq_eq_true h1; subst this
    rw [h1] at hx; cases hx
    obtain ⟨o', ho', hk'⟩ := PRE_first_tail_x15_r0_body.arr142_2665
    rw [ho] at ho'; cases ho'
    rw [hk'] at hk; cases hk
    simp [PRE_first_tail_x15_r0_body.arrEl142_2665]

end Host.Load.Run.Tpl
end

section -- SiteZ142
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! The compaction's state shift at call site 142 of chain `PRE_first_tail_x15_r0_body` (`Conv.compact_shift`): the call `PRE_first_tail_x15_r0_body.s1375`, the merged
state `PRE_first_tail_x15_r0_body.s1376`, the canonical state `PRE_first_tail_x15_r0_body.s1377`; its frames [2665,2673467,2673472,2673473] (kept arrays [2665,2673467]). -/

-- the map's places and counters
kernel_rfl PRE_first_tail_x15_r0_body.zpl142 : PRE_first_tail_x15_r0_body.pl142.all (Nat.ble PRE_first_tail_x15_r0_body.s1375.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zplnd142 : nodupT PRE_first_tail_x15_r0_body.pl142 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.zn1142 : Nat.ble PRE_first_tail_x15_r0_body.s1375.next 2786675 = true
kernel_rfl PRE_first_tail_x15_r0_body.zfirst142 : Nat.ble aFirst PRE_first_tail_x15_r0_body.s1375.next = true
kernel_rfl PRE_first_tail_x15_r0_body.zscn142 : PRE_first_tail_x15_r0_body.s1377.next = PRE_first_tail_x15_r0_body.s1375.next + PRE_first_tail_x15_r0_body.pl142.length
kernel_rfl PRE_first_tail_x15_r0_body.zsmn142 : PRE_first_tail_x15_r0_body.s1376.next = 2786675
kernel_rfl PRE_first_tail_x15_r0_body.zgrow142 : Nat.ble PRE_first_tail_x15_r0_body.s1377.next PRE_first_tail_x15_r0_body.s1376.next = true
-- the tables
kernel_rfl PRE_first_tail_x15_r0_body.zfresh142 : PRE_first_tail_x15_r0_body.S1375.tab.all (fun e => PRE_first_tail_x15_r0_body.cws142.all fun v => e.noVar v) = true
kernel_rfl PRE_first_tail_x15_r0_body.zcnd142 : nodupT PRE_first_tail_x15_r0_body.cws142 PTrie.nil = true
kernel_rfl PRE_first_tail_x15_r0_body.znrHi142 : PRE_first_tail_x15_r0_body.nr142.all (fun r => Nat.blt r PRE_first_tail_x15_r0_body.S1376.tab.length) = true
-- the frames: every framed address below the call's counter; the kept arrays the chain start's, extended in the merged state
kernel_rfl PRE_first_tail_x15_r0_body.zfrlt142 : [2665, 2673467, 2673472, 2673473].all (fun a => Nat.blt a PRE_first_tail_x15_r0_body.s1375.next) = true
kernel_rfl PRE_first_tail_x15_r0_body.zg142_2665 : PRE_first_tail_x15_r0_body.s1377.heap.get 2665 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1377 2665))
kernel_rfl PRE_first_tail_x15_r0_body.zk142_2665 : (objOf PRE_first_tail_x15_r0_body.s1377 2665).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2665)
kernel_rfl PRE_first_tail_x15_r0_body.zm142_2665 : PRE_first_tail_x15_r0_body.s1376.heap.get 2665 = some (.obj { PRE_first_tail_x15_r0_body.kappa142.obj (objOf PRE_first_tail_x15_r0_body.s1377 2665) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2665 ++ (arrOf PRE_first_tail_x15_r0_body.s1376 2665).drop (arrOf PRE_first_tail_x15_r0_body.s0 2665).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zg142_2673467 : PRE_first_tail_x15_r0_body.s1377.heap.get 2673467 = some (.obj (objOf PRE_first_tail_x15_r0_body.s1377 2673467))
kernel_rfl PRE_first_tail_x15_r0_body.zk142_2673467 : (objOf PRE_first_tail_x15_r0_body.s1377 2673467).kind = .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467)
kernel_rfl PRE_first_tail_x15_r0_body.zm142_2673467 : PRE_first_tail_x15_r0_body.s1376.heap.get 2673467 = some (.obj { PRE_first_tail_x15_r0_body.kappa142.obj (objOf PRE_first_tail_x15_r0_body.s1377 2673467) with
  kind := .array (arrOf PRE_first_tail_x15_r0_body.s0 2673467 ++ (arrOf PRE_first_tail_x15_r0_body.s1376 2673467).drop (arrOf PRE_first_tail_x15_r0_body.s0 2673467).length) })
kernel_rfl PRE_first_tail_x15_r0_body.zw142_4910 : (PRE_first_tail_x15_r0_body.s1377.heap.get 4910).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw142_2673472 : (PRE_first_tail_x15_r0_body.s1377.heap.get 2673472).isSome = true
kernel_rfl PRE_first_tail_x15_r0_body.zw142_2673473 : (PRE_first_tail_x15_r0_body.s1377.heap.get 2673473).isSome = true
-- the heap: the changed list in range, holding the stage's written and fresh addresses; the canonical side's image
kernel_rfl PRE_first_tail_x15_r0_body.zclbd142 : PRE_first_tail_x15_r0_body.cl142.all (fun b => Nat.blt (b / 4096) (4 ^ 31)) = true
kernel_rfl PRE_first_tail_x15_r0_body.zwr142 : PRE_first_tail_x15_r0_body.st142.wr.all (fun b => !Nat.blt b PRE_first_tail_x15_r0_body.s1375.next || PRE_first_tail_x15_r0_body.cl142.contains b) = true
def PRE_first_tail_x15_r0_body.zl142 : List Nat := PRE_first_tail_x15_r0_body.cl142.filter fun a => !(List.contains [2665, 2673467] a)
kernel_rfl PRE_first_tail_x15_r0_body.zimgE142 : PRE_first_tail_x15_r0_body.zl142.map (fun a => PRE_first_tail_x15_r0_body.s1376.heap.get (PRE_first_tail_x15_r0_body.kappa142.a a)) = PRE_first_tail_x15_r0_body.zl142.map (fun a => (PRE_first_tail_x15_r0_body.s1377.heap.get a).map PRE_first_tail_x15_r0_body.kappa142.hobj)
theorem PRE_first_tail_x15_r0_body.zimg142 : HeapImg PRE_first_tail_x15_r0_body.kappa142 PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.s1376 PRE_first_tail_x15_r0_body.zl142 := PRE_first_tail_x15_r0_body.zimgE142
-- the roots and their supports
kernel_rfl PRE_first_tail_x15_r0_body.zctl142 : PRE_first_tail_x15_r0_body.s1376.ctl = PRE_first_tail_x15_r0_body.kappa142.ctl PRE_first_tail_x15_r0_body.s1377.ctl
kernel_rfl PRE_first_tail_x15_r0_body.zstack142 : PRE_first_tail_x15_r0_body.s1376.stack = PRE_first_tail_x15_r0_body.s1377.stack.map PRE_first_tail_x15_r0_body.kappa142.frame
kernel_rfl PRE_first_tail_x15_r0_body.zjobs142 : PRE_first_tail_x15_r0_body.s1376.jobs = PRE_first_tail_x15_r0_body.s1377.jobs.map PRE_first_tail_x15_r0_body.kappa142.job
kernel_rfl PRE_first_tail_x15_r0_body.zstores142 : PRE_first_tail_x15_r0_body.s1376.stores = PRE_first_tail_x15_r0_body.kappa142.stores PRE_first_tail_x15_r0_body.s1377.stores
kernel_rfl PRE_first_tail_x15_r0_body.zroots142 : checkRootsSupp PRE_first_tail_x15_r0_body.s1377 6149 = true
kernel_rfl PRE_first_tail_x15_r0_body.znC142 : PRE_first_tail_x15_r0_body.S1375.tab.length + PRE_first_tail_x15_r0_body.cws142.length = 6149
-- the map as `Conv.compact_shift` states it (the call's counters for the literals)
kernel_rfl PRE_first_tail_x15_r0_body.zkap142 : PRE_first_tail_x15_r0_body.kappa142 = Conv.Map.compact PRE_first_tail_x15_r0_body.s1375.next 2786675 PRE_first_tail_x15_r0_body.S1375.tab.length PRE_first_tail_x15_r0_body.pl142 (PRE_first_tail_x15_r0_body.nr142.map NumV.ref) PRE_first_tail_x15_r0_body.kd142.big
  PRE_first_tail_x15_r0_body.kd142.region PRE_first_tail_x15_r0_body.kd142.nodeF
-- the bridge inactive at the canonical state (`Conv.FullShiftQ.toX`; the merged state's bridge is the canonical's: cbridge)
theorem PRE_first_tail_x15_r0_body.zbin142 : (Host.Ts.Sim.Full.bridgeOf PRE_first_tail_x15_r0_body.s1377.ffi).active = false := (Host.Load.Boot.replay_active Host.Load.Run.Prompt.P.oblog2818)
-- the JS bookkeeping's step (`Conv.JClean.step` over the changed list) and the canonical roots' bigint freedom
kernel_rfl PRE_first_tail_x15_r0_body.zjc142 : Conv.jcleanListB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.cl142 = true
kernel_rfl PRE_first_tail_x15_r0_body.zrootsB142 : noBigRootsP (fun i => !Conv.oldBigB (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) i) PRE_first_tail_x15_r0_body.s1377.trace PRE_first_tail_x15_r0_body.s1377 = true
kernel_rfl PRE_first_tail_x15_r0_body.zhm142 : Nat.ble (Host.Load.Layers.toLoad PRE_first_tail_x15_r0_body.s0.ffi).mlx.nnext 18099 = true
theorem PRE_first_tail_x15_r0_body.cjcl142 (h : Conv.JClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1375) : Conv.JClean (⟨21006, 18099, 2786673, 6149⟩ : Conv.Cnt) PRE_first_tail_x15_r0_body.s1377 :=
  Conv.JClean.step h (Conv.Cnt.le_of_leB PRE_first_tail_x15_r0_body.cle142)
    (Conv.heap_off_setAll PRE_first_tail_x15_r0_body.cheap142 fun a ha => Nat.blt_eq.mp (List.all_eq_true.mp PRE_first_tail_x15_r0_body.zclbd142 a ha)) PRE_first_tail_x15_r0_body.zjc142

end Host.Load.Run.Tpl
end

section -- st142/TypedLast
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st142.bodyLast from PRE_first_tail_x15_r0_body.st142.s1 to PRE_first_tail_x15_r0_body.st142.s2 :
  interpS (step PRE_first_tail_x15_r0_body.st142.F PRE_first_tail_x15_r0_body.st142.s1).run PRE_first_tail_x15_r0_body.st142.S1 = some (PRE_first_tail_x15_r0_body.st142.s2, PRE_first_tail_x15_r0_body.st142.S2)
kernel_rfl PRE_first_tail_x15_r0_body.st142.bodyHalt : isHalt PRE_first_tail_x15_r0_body.st142.s1.ctl = false
kernel_rfl PRE_first_tail_x15_r0_body.st142.bodyTopCheck : noBlockTop PRE_first_tail_x15_r0_body.st142.s2.stack = true

end Host.Load.Run.Tpl
end

section -- st142/TypedOk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

noncomputable def PRE_first_tail_x15_r0_body.st142.bodyOkL (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st142.F.S → SSrv → Bool :=
  okLocal (Host.Ts.Sim.Compose.VWFrames.bodyOk bytes rows)

noncomputable def PRE_first_tail_x15_r0_body.st142.bodyOkLN (bytes : List Byte) (rows : Nat) : St PRE_first_tail_x15_r0_body.st142.F.S → FSrv → Bool :=
  okLocalN (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows)

theorem PRE_first_tail_x15_r0_body.st142.bodyOkLN_ok (bytes : List Byte) (rows : Nat) (s : St PRE_first_tail_x15_r0_body.st142.F.S) (c : FSrv) (h : c.Wf) :
    PRE_first_tail_x15_r0_body.st142.bodyOkLN bytes rows s c = PRE_first_tail_x15_r0_body.st142.bodyOkL bytes rows s c.toS :=
  okLocalN_ok (Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok bytes rows) s c h

kernel_rfl PRE_first_tail_x15_r0_body.st142.bodyAccepted0 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st142.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st142.s0 PRE_first_tail_x15_r0_body.st142.S0) = fun _ _ => true

kernel_rfl PRE_first_tail_x15_r0_body.st142.bodyAccepted1 :
  (fun (bytes : List Byte) (rows : Nat) => PRE_first_tail_x15_r0_body.st142.bodyOkL bytes rows PRE_first_tail_x15_r0_body.st142.s1 PRE_first_tail_x15_r0_body.st142.S1) = fun _ _ => true

end Host.Load.Run.Tpl
end

import host.sim.template.a4dec_ord.SiteSn1_0
import host.sim.template.a4dec_ord.SiteSn1_1
import host.sim.template.a4dec_ord.SiteSn1_2
import host.sim.template.a4dec_ord.SiteSn1_3
import host.sim.template.a4dec_ord.SiteSn1_4
import host.sim.template.a4dec_ord.SiteSn1_5
import host.sim.template.a4dec_ord.SiteSn1_6
import host.sim.template.a4dec_ord.SiteSn1_7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_ord.fh1 : DEC_ord.clo1.all (handleOK DEC_ord.kappa1 DEC_ord.P1.lo DEC_ord.cx0_1.mlx DEC_ord.cx1_1.mlx) = true
kernel_rfl DEC_ord.fo1 : DEC_ord.clo1.map (fun h => DEC_ord.cx1_1.mlx.objs.get (DEC_ord.kappa1.handle h)) = DEC_ord.clo1.map (fun h => (DEC_ord.cx0_1.mlx.objs.get h).map DEC_ord.kappa1.nobj)
kernel_rfl DEC_ord.fok1 : DEC_ord.clo1.all (objOK DEC_ord.kappa1 DEC_ord.P1.NL DEC_ord.cx0_1.mlx) = true
kernel_rfl DEC_ord.fnd1_end : ((((DEC_ord.cln1).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_ord.fnd1 : (DEC_ord.cln1).all (nodeOKF DEC_ord.kappa1 DEC_ord.P1 DEC_ord.cx0_1.mlx DEC_ord.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_ord.fnd1_0 (all_take_drop 600 DEC_ord.fnd1_1 (all_take_drop 600 DEC_ord.fnd1_2 (all_take_drop 600 DEC_ord.fnd1_3 (all_of_nil DEC_ord.fnd1_end))))
kernel_rfl DEC_ord.fp1_end : (((((DEC_ord.cln1.filter (fullB DEC_ord.P1))).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_ord.fp1 : ((DEC_ord.cln1.filter (fullB DEC_ord.P1))).map (fun i => (DEC_ord.cx1_1.mlx.nodes.get (DEC_ord.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_ord.cln1.filter (fullB DEC_ord.P1))).map (fun i => (DEC_ord.cx0_1.mlx.nodes.get i).map fun nd => DEC_ord.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_ord.fp1_0 (map_take_drop 600 DEC_ord.fp1_1 (map_take_drop 600 DEC_ord.fp1_2 (map_take_drop 600 DEC_ord.fp1_3 (map_of_nil DEC_ord.fp1_end))))
kernel_rfl DEC_ord.fnordI1 : incrB DEC_ord.kd1.nodeF (List.range' 22540 2373) = true
kernel_rfl DEC_ord.fnordK1 : (PTrie.keysA DEC_ord.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24913) = true
kernel_rfl DEC_ord.fnordL1 : (DEC_ord.cln1.filter (Nat.ble DEC_ord.P1.N0)).all (fun i => Nat.ble i (DEC_ord.kd1.nodeF i) && (Nat.blt i 24913 || Nat.ble DEC_ord.kd1.nn0 i)) = true
theorem DEC_ord.fnord1 : (DEC_ord.cln1.filter (Nat.ble DEC_ord.P1.N0)).all (fun i => Nat.ble i (DEC_ord.kd1.nodeF i) &&
    (PTrie.keysA DEC_ord.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_ord.kd1.nodeF j) (DEC_ord.kd1.nodeF i)) = true :=
  cnord_of DEC_ord.cnlow1 DEC_ord.cnn11 DEC_ord.fnordI1 DEC_ord.fnordK1 DEC_ord.fnordL1
kernel_rfl DEC_ord.fi1 : DEC_ord.cli1.all (pnB DEC_ord.cx0_1.mlx) = true
kernel_rfl DEC_ord.fii1 : DEC_ord.cli1.all (fun k => decide (DEC_ord.cx1_1.mlx.items.get (DEC_ord.kappa1.node k) = (DEC_ord.cx0_1.mlx.items.get k).map DEC_ord.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_ord.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P1.NL) (cl : SSt (· < 353) DEC_ord.cx0_1.mlx) :
    Conv.MFoot DEC_ord.P1 353 DEC_ord.kappa1 DEC_ord.kd1 DEC_ord.khinv1 DEC_ord.kninv1 (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx DEC_ord.cx0_1.mlx DEC_ord.cx1_1.mlx (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_ord.clo1 DEC_ord.cln1 DEC_ord.cli1 DEC_ord.cwS1 DEC_ord.cnS1 DEC_ord.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_ord.cnh01, DEC_ord.cnh11, DEC_ord.cnn01, DEC_ord.cnn11, DEC_ord.cplo1, DEC_ord.ccnt1, DEC_ord.cnband1, DEC_ord.chbelow1, DEC_ord.chren1, DEC_ord.cband1, DEC_ord.cnh1pos1, DEC_ord.cnren1, DEC_ord.cnlow1, DEC_ord.cabs0a1, DEC_ord.cabs0b1, DEC_ord.ctok11, DEC_ord.cpend1, DEC_ord.cerrh1, DEC_ord.cfiles1, DEC_ord.carch1, DEC_ord.csizes1, DEC_ord.cwired1, DEC_ord.cfix1, clean, DEC_ord.fcxn1, DEC_ord.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_ord.fle01, DEC_ord.fnk1, DEC_ord.ckA1, DEC_ord.cobjsK1, DEC_ord.cnodesK1, DEC_ord.citemsK1, DEC_ord.f1A1, DEC_ord.f1O1, DEC_ord.f1N1, DEC_ord.f1I1, DEC_ord.fbd1, DEC_ord.fincW1, DEC_ord.fincI1, DEC_ord.fincN1, DEC_ord.flnF1, DEC_ord.fh1, DEC_ord.fo1, DEC_ord.fok1, DEC_ord.fnd1, DEC_ord.fp1, DEC_ord.fnord1, DEC_ord.fi1, DEC_ord.fii1⟩
theorem DEC_ord.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P1.NL) (cl : SSt (· < 353) DEC_ord.cx0_1.mlx) : NShift DEC_ord.P1 353 DEC_ord.kappa1 DEC_ord.cx0_1 DEC_ord.cx1_1 :=
  Conv.nshift_of_foot (DEC_ord.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_ord.chost1 (compact_a_eq DEC_ord.ckn01 DEC_ord.ckn11 DEC_ord.ckheap1 DEC_ord.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_ord.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s4.ffi).getD PTrie.nil
noncomputable def DEC_ord.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_ord.s4.ffi) = some DEC_ord.fxC_1
kernel_rfl DEC_ord.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_ord.s4.ffi) = some DEC_ord.krC_1
noncomputable def DEC_ord.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s6.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_ord.s6.ffi) = some DEC_ord.fx0_1
kernel_rfl DEC_ord.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_ord.s6.ffi) = some DEC_ord.kr0_1
noncomputable def DEC_ord.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_ord.s5.ffi).getD PTrie.nil
noncomputable def DEC_ord.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_ord.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_ord.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_ord.s5.ffi) = some DEC_ord.fx1_1
kernel_rfl DEC_ord.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_ord.s5.ffi) = some DEC_ord.kr1_1
kernel_rfl DEC_ord.ff01 : DEC_ord.fx0_1 = Stage.setAll DEC_ord.fxC_1 (DEC_ord.clo1.filterMap fun i => (DEC_ord.fx0_1.get i).map (i, ·))
kernel_rfl DEC_ord.ff11 : DEC_ord.fx1_1 = Stage.setAll DEC_ord.fxC_1 (DEC_ord.cwS1.filterMap fun i => (DEC_ord.fx1_1.get i).map (i, ·))
kernel_rfl DEC_ord.ffck1 : freedLB DEC_ord.kappa1 DEC_ord.cx0_1.mlx DEC_ord.fx0_1 DEC_ord.fx1_1 DEC_ord.clo1 = true
kernel_rfl DEC_ord.fkf01 : DEC_ord.kr0_1.flags = Stage.setAll DEC_ord.krC_1.flags (DEC_ord.clo1.filterMap fun i => (DEC_ord.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt01 : DEC_ord.kr0_1.targs = Stage.setAll DEC_ord.krC_1.targs (DEC_ord.clo1.filterMap fun i => (DEC_ord.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkf11 : DEC_ord.kr1_1.flags = Stage.setAll DEC_ord.krC_1.flags (DEC_ord.cwS1.filterMap fun i => (DEC_ord.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_ord.fkt11 : DEC_ord.kr1_1.targs = Stage.setAll DEC_ord.krC_1.targs (DEC_ord.cwS1.filterMap fun i => (DEC_ord.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_ord.fkck1 : krecLB DEC_ord.kappa1 353 DEC_ord.cx0_1.mlx DEC_ord.kr0_1 DEC_ord.kr1_1 DEC_ord.clo1 = true
kernel_rfl DEC_ord.fkn1 : Nat.ble 129 353 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_ord.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_ord.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_ord.s6.ffi
kernel_rfl DEC_ord.cpendR1 : pendRegB DEC_ord.kappa1 (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx = true
kernel_rfl DEC_ord.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_ord.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_ord.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_ord.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_ord.P1.NL) (cl : SSt (· < 353) DEC_ord.cx0_1.mlx)
    (hobjC : ∀ h, DEC_ord.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_ord.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_ord.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_ord.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_ord.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_ord.P1 353 DEC_ord.kappa1 DEC_ord.s6.ffi DEC_ord.s5.ffi :=
  ⟨DEC_ord.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_ord.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_ord.ctokSupp1 t ht),
    DEC_ord.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s5.ffi) (DEC_ord.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.ofx0_1 DEC_ord.ofx1_1 hobjC DEC_ord.ff01 DEC_ord.ff11 DEC_ord.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_ord.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_ord.s5.ffi) (DEC_ord.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_ord.okr0_1 DEC_ord.okr1_1 (Nat.le_of_ble_eq_true DEC_ord.fkn1) hfC htC hclC
      DEC_ord.fkf01 DEC_ord.fkt01 DEC_ord.fkf11 DEC_ord.fkt11 DEC_ord.fkck1,
    pendReg_of rfl DEC_ord.cnh01 DEC_ord.cnh11 (Nat.le_of_ble_eq_true DEC_ord.cpendLe1) DEC_ord.cpendR1⟩

end Host.Load.Run.Tpl

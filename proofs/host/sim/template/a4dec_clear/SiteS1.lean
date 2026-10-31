import host.sim.template.a4dec_clear.SiteSn1_0
import host.sim.template.a4dec_clear.SiteSn1_1
import host.sim.template.a4dec_clear.SiteSn1_2
import host.sim.template.a4dec_clear.SiteSn1_3
import host.sim.template.a4dec_clear.SiteSn1_4
import host.sim.template.a4dec_clear.SiteSn1_5
import host.sim.template.a4dec_clear.SiteSn1_6
import host.sim.template.a4dec_clear.SiteSn1_7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_clear.fh1 : DEC_clear.clo1.all (handleOK DEC_clear.kappa1 DEC_clear.P1.lo DEC_clear.cx0_1.mlx DEC_clear.cx1_1.mlx) = true
kernel_rfl DEC_clear.fo1 : DEC_clear.clo1.map (fun h => DEC_clear.cx1_1.mlx.objs.get (DEC_clear.kappa1.handle h)) = DEC_clear.clo1.map (fun h => (DEC_clear.cx0_1.mlx.objs.get h).map DEC_clear.kappa1.nobj)
kernel_rfl DEC_clear.fok1 : DEC_clear.clo1.all (objOK DEC_clear.kappa1 DEC_clear.P1.NL DEC_clear.cx0_1.mlx) = true
kernel_rfl DEC_clear.fnd1_end : ((((DEC_clear.cln1).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clear.fnd1 : (DEC_clear.cln1).all (nodeOKF DEC_clear.kappa1 DEC_clear.P1 DEC_clear.cx0_1.mlx DEC_clear.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_clear.fnd1_0 (all_take_drop 600 DEC_clear.fnd1_1 (all_take_drop 600 DEC_clear.fnd1_2 (all_take_drop 600 DEC_clear.fnd1_3 (all_of_nil DEC_clear.fnd1_end))))
kernel_rfl DEC_clear.fp1_end : (((((DEC_clear.cln1.filter (fullB DEC_clear.P1))).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_clear.fp1 : ((DEC_clear.cln1.filter (fullB DEC_clear.P1))).map (fun i => (DEC_clear.cx1_1.mlx.nodes.get (DEC_clear.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_clear.cln1.filter (fullB DEC_clear.P1))).map (fun i => (DEC_clear.cx0_1.mlx.nodes.get i).map fun nd => DEC_clear.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_clear.fp1_0 (map_take_drop 600 DEC_clear.fp1_1 (map_take_drop 600 DEC_clear.fp1_2 (map_take_drop 600 DEC_clear.fp1_3 (map_of_nil DEC_clear.fp1_end))))
kernel_rfl DEC_clear.fnordI1 : incrB DEC_clear.kd1.nodeF (List.range' 22540 2373) = true
kernel_rfl DEC_clear.fnordK1 : (PTrie.keysA DEC_clear.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24913) = true
kernel_rfl DEC_clear.fnordL1 : (DEC_clear.cln1.filter (Nat.ble DEC_clear.P1.N0)).all (fun i => Nat.ble i (DEC_clear.kd1.nodeF i) && (Nat.blt i 24913 || Nat.ble DEC_clear.kd1.nn0 i)) = true
theorem DEC_clear.fnord1 : (DEC_clear.cln1.filter (Nat.ble DEC_clear.P1.N0)).all (fun i => Nat.ble i (DEC_clear.kd1.nodeF i) &&
    (PTrie.keysA DEC_clear.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_clear.kd1.nodeF j) (DEC_clear.kd1.nodeF i)) = true :=
  cnord_of DEC_clear.cnlow1 DEC_clear.cnn11 DEC_clear.fnordI1 DEC_clear.fnordK1 DEC_clear.fnordL1
kernel_rfl DEC_clear.fi1 : DEC_clear.cli1.all (pnB DEC_clear.cx0_1.mlx) = true
kernel_rfl DEC_clear.fii1 : DEC_clear.cli1.all (fun k => decide (DEC_clear.cx1_1.mlx.items.get (DEC_clear.kappa1.node k) = (DEC_clear.cx0_1.mlx.items.get k).map DEC_clear.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_clear.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P1.NL) (cl : SSt (· < 353) DEC_clear.cx0_1.mlx) :
    Conv.MFoot DEC_clear.P1 353 DEC_clear.kappa1 DEC_clear.kd1 DEC_clear.khinv1 DEC_clear.kninv1 (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx DEC_clear.cx0_1.mlx DEC_clear.cx1_1.mlx (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) DEC_clear.clo1 DEC_clear.cln1 DEC_clear.cli1 DEC_clear.cwS1 DEC_clear.cnS1 DEC_clear.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_clear.cnh01, DEC_clear.cnh11, DEC_clear.cnn01, DEC_clear.cnn11, DEC_clear.cplo1, DEC_clear.ccnt1, DEC_clear.cnband1, DEC_clear.chbelow1, DEC_clear.chren1, DEC_clear.cband1, DEC_clear.cnh1pos1, DEC_clear.cnren1, DEC_clear.cnlow1, DEC_clear.cabs0a1, DEC_clear.cabs0b1, DEC_clear.ctok11, DEC_clear.cpend1, DEC_clear.cerrh1, DEC_clear.cfiles1, DEC_clear.carch1, DEC_clear.csizes1, DEC_clear.cwired1, DEC_clear.cfix1, clean, DEC_clear.fcxn1, DEC_clear.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_clear.fle01, DEC_clear.fnk1, DEC_clear.ckA1, DEC_clear.cobjsK1, DEC_clear.cnodesK1, DEC_clear.citemsK1, DEC_clear.f1A1, DEC_clear.f1O1, DEC_clear.f1N1, DEC_clear.f1I1, DEC_clear.fbd1, DEC_clear.fincW1, DEC_clear.fincI1, DEC_clear.fincN1, DEC_clear.flnF1, DEC_clear.fh1, DEC_clear.fo1, DEC_clear.fok1, DEC_clear.fnd1, DEC_clear.fp1, DEC_clear.fnord1, DEC_clear.fi1, DEC_clear.fii1⟩
theorem DEC_clear.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P1.NL) (cl : SSt (· < 353) DEC_clear.cx0_1.mlx) : NShift DEC_clear.P1 353 DEC_clear.kappa1 DEC_clear.cx0_1 DEC_clear.cx1_1 :=
  Conv.nshift_of_foot (DEC_clear.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_clear.chost1 (compact_a_eq DEC_clear.ckn01 DEC_clear.ckn11 DEC_clear.ckheap1 DEC_clear.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_clear.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s4.ffi).getD PTrie.nil
noncomputable def DEC_clear.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_clear.s4.ffi) = some DEC_clear.fxC_1
kernel_rfl DEC_clear.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_clear.s4.ffi) = some DEC_clear.krC_1
noncomputable def DEC_clear.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s6.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_clear.s6.ffi) = some DEC_clear.fx0_1
kernel_rfl DEC_clear.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_clear.s6.ffi) = some DEC_clear.kr0_1
noncomputable def DEC_clear.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_clear.s5.ffi).getD PTrie.nil
noncomputable def DEC_clear.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_clear.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_clear.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_clear.s5.ffi) = some DEC_clear.fx1_1
kernel_rfl DEC_clear.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_clear.s5.ffi) = some DEC_clear.kr1_1
kernel_rfl DEC_clear.ff01 : DEC_clear.fx0_1 = Stage.setAll DEC_clear.fxC_1 (DEC_clear.clo1.filterMap fun i => (DEC_clear.fx0_1.get i).map (i, ·))
kernel_rfl DEC_clear.ff11 : DEC_clear.fx1_1 = Stage.setAll DEC_clear.fxC_1 (DEC_clear.cwS1.filterMap fun i => (DEC_clear.fx1_1.get i).map (i, ·))
kernel_rfl DEC_clear.ffck1 : freedLB DEC_clear.kappa1 DEC_clear.cx0_1.mlx DEC_clear.fx0_1 DEC_clear.fx1_1 DEC_clear.clo1 = true
kernel_rfl DEC_clear.fkf01 : DEC_clear.kr0_1.flags = Stage.setAll DEC_clear.krC_1.flags (DEC_clear.clo1.filterMap fun i => (DEC_clear.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt01 : DEC_clear.kr0_1.targs = Stage.setAll DEC_clear.krC_1.targs (DEC_clear.clo1.filterMap fun i => (DEC_clear.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkf11 : DEC_clear.kr1_1.flags = Stage.setAll DEC_clear.krC_1.flags (DEC_clear.cwS1.filterMap fun i => (DEC_clear.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_clear.fkt11 : DEC_clear.kr1_1.targs = Stage.setAll DEC_clear.krC_1.targs (DEC_clear.cwS1.filterMap fun i => (DEC_clear.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_clear.fkck1 : krecLB DEC_clear.kappa1 353 DEC_clear.cx0_1.mlx DEC_clear.kr0_1 DEC_clear.kr1_1 DEC_clear.clo1 = true
kernel_rfl DEC_clear.fkn1 : Nat.ble 129 353 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_clear.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_clear.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_clear.s6.ffi
kernel_rfl DEC_clear.cpendR1 : pendRegB DEC_clear.kappa1 (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx = true
kernel_rfl DEC_clear.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_clear.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_clear.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_clear.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_clear.P1.NL) (cl : SSt (· < 353) DEC_clear.cx0_1.mlx)
    (hobjC : ∀ h, DEC_clear.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_clear.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_clear.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_clear.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_clear.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123642, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_clear.P1 353 DEC_clear.kappa1 DEC_clear.s6.ffi DEC_clear.s5.ffi :=
  ⟨DEC_clear.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_clear.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_clear.ctokSupp1 t ht),
    DEC_clear.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s5.ffi) (DEC_clear.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.ofx0_1 DEC_clear.ofx1_1 hobjC DEC_clear.ff01 DEC_clear.ff11 DEC_clear.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_clear.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_clear.s5.ffi) (DEC_clear.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_clear.okr0_1 DEC_clear.okr1_1 (Nat.le_of_ble_eq_true DEC_clear.fkn1) hfC htC hclC
      DEC_clear.fkf01 DEC_clear.fkt01 DEC_clear.fkf11 DEC_clear.fkt11 DEC_clear.fkck1,
    pendReg_of rfl DEC_clear.cnh01 DEC_clear.cnh11 (Nat.le_of_ble_eq_true DEC_clear.cpendLe1) DEC_clear.cpendR1⟩

end Host.Load.Run.Tpl

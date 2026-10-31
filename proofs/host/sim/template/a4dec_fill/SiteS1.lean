import host.sim.template.a4dec_fill.SiteSn1_0
import host.sim.template.a4dec_fill.SiteSn1_1
import host.sim.template.a4dec_fill.SiteSn1_2
import host.sim.template.a4dec_fill.SiteSn1_3
import host.sim.template.a4dec_fill.SiteSn1_4
import host.sim.template.a4dec_fill.SiteSn1_5
import host.sim.template.a4dec_fill.SiteSn1_6
import host.sim.template.a4dec_fill.SiteSn1_7
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

-- the checks over the changed lists
kernel_rfl DEC_fill.fh1 : DEC_fill.clo1.all (handleOK DEC_fill.kappa1 DEC_fill.P1.lo DEC_fill.cx0_1.mlx DEC_fill.cx1_1.mlx) = true
kernel_rfl DEC_fill.fo1 : DEC_fill.clo1.map (fun h => DEC_fill.cx1_1.mlx.objs.get (DEC_fill.kappa1.handle h)) = DEC_fill.clo1.map (fun h => (DEC_fill.cx0_1.mlx.objs.get h).map DEC_fill.kappa1.nobj)
kernel_rfl DEC_fill.fok1 : DEC_fill.clo1.all (objOK DEC_fill.kappa1 DEC_fill.P1.NL DEC_fill.cx0_1.mlx) = true
kernel_rfl DEC_fill.fnd1_end : ((((DEC_fill.cln1).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_fill.fnd1 : (DEC_fill.cln1).all (nodeOKF DEC_fill.kappa1 DEC_fill.P1 DEC_fill.cx0_1.mlx DEC_fill.cx1_1.mlx) = true :=
  all_take_drop 600 DEC_fill.fnd1_0 (all_take_drop 600 DEC_fill.fnd1_1 (all_take_drop 600 DEC_fill.fnd1_2 (all_take_drop 600 DEC_fill.fnd1_3 (all_of_nil DEC_fill.fnd1_end))))
kernel_rfl DEC_fill.fp1_end : (((((DEC_fill.cln1.filter (fullB DEC_fill.P1))).drop 600).drop 600).drop 600).drop 600 = []
theorem DEC_fill.fp1 : ((DEC_fill.cln1.filter (fullB DEC_fill.P1))).map (fun i => (DEC_fill.cx1_1.mlx.nodes.get (DEC_fill.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((DEC_fill.cln1.filter (fullB DEC_fill.P1))).map (fun i => (DEC_fill.cx0_1.mlx.nodes.get i).map fun nd => DEC_fill.kappa1.prim nd.prim) :=
  map_take_drop 600 DEC_fill.fp1_0 (map_take_drop 600 DEC_fill.fp1_1 (map_take_drop 600 DEC_fill.fp1_2 (map_take_drop 600 DEC_fill.fp1_3 (map_of_nil DEC_fill.fp1_end))))
kernel_rfl DEC_fill.fnordI1 : incrB DEC_fill.kd1.nodeF (List.range' 22540 2341) = true
kernel_rfl DEC_fill.fnordK1 : (PTrie.keysA DEC_fill.kd1.node).all (fun k => Nat.ble 22540 k && Nat.blt k 24881) = true
kernel_rfl DEC_fill.fnordL1 : (DEC_fill.cln1.filter (Nat.ble DEC_fill.P1.N0)).all (fun i => Nat.ble i (DEC_fill.kd1.nodeF i) && (Nat.blt i 24881 || Nat.ble DEC_fill.kd1.nn0 i)) = true
theorem DEC_fill.fnord1 : (DEC_fill.cln1.filter (Nat.ble DEC_fill.P1.N0)).all (fun i => Nat.ble i (DEC_fill.kd1.nodeF i) &&
    (PTrie.keysA DEC_fill.kd1.node).all fun j => !Nat.blt j i || Nat.blt (DEC_fill.kd1.nodeF j) (DEC_fill.kd1.nodeF i)) = true :=
  cnord_of DEC_fill.cnlow1 DEC_fill.cnn11 DEC_fill.fnordI1 DEC_fill.fnordK1 DEC_fill.fnordL1
kernel_rfl DEC_fill.fi1 : DEC_fill.cli1.all (pnB DEC_fill.cx0_1.mlx) = true
kernel_rfl DEC_fill.fii1 : DEC_fill.cli1.all (fun k => decide (DEC_fill.cx1_1.mlx.items.get (DEC_fill.kappa1.node k) = (DEC_fill.cx0_1.mlx.items.get k).map DEC_fill.kappa1.nv)) = true
/-- **The compaction's footprint.** -/
theorem DEC_fill.cfoot1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P1.NL) (cl : SSt (· < 289) DEC_fill.cx0_1.mlx) :
    Conv.MFoot DEC_fill.P1 289 DEC_fill.kappa1 DEC_fill.kd1 DEC_fill.khinv1 DEC_fill.kninv1 (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx DEC_fill.cx0_1.mlx DEC_fill.cx1_1.mlx (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) DEC_fill.clo1 DEC_fill.cln1 DEC_fill.cli1 DEC_fill.cwS1 DEC_fill.cnS1 DEC_fill.ciS1 :=
  ⟨rfl, rfl, rfl, DEC_fill.cnh01, DEC_fill.cnh11, DEC_fill.cnn01, DEC_fill.cnn11, DEC_fill.cplo1, DEC_fill.ccnt1, DEC_fill.cnband1, DEC_fill.chbelow1, DEC_fill.chren1, DEC_fill.cband1, DEC_fill.cnh1pos1, DEC_fill.cnren1, DEC_fill.cnlow1, DEC_fill.cabs0a1, DEC_fill.cabs0b1, DEC_fill.ctok11, DEC_fill.cpend1, DEC_fill.cerrh1, DEC_fill.cfiles1, DEC_fill.carch1, DEC_fill.csizes1, DEC_fill.cwired1, DEC_fill.cfix1, clean, DEC_fill.fcxn1, DEC_fill.fcnn1, hltC, nltC, itemsC, tracedC, cl, DEC_fill.fle01, DEC_fill.fnk1, DEC_fill.ckA1, DEC_fill.cobjsK1, DEC_fill.cnodesK1, DEC_fill.citemsK1, DEC_fill.f1A1, DEC_fill.f1O1, DEC_fill.f1N1, DEC_fill.f1I1, DEC_fill.fbd1, DEC_fill.fincW1, DEC_fill.fincI1, DEC_fill.fincN1, DEC_fill.flnF1, DEC_fill.fh1, DEC_fill.fo1, DEC_fill.fok1, DEC_fill.fnd1, DEC_fill.fp1, DEC_fill.fnord1, DEC_fill.fi1, DEC_fill.fii1⟩
theorem DEC_fill.cnshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P1.NL) (cl : SSt (· < 289) DEC_fill.cx0_1.mlx) : NShift DEC_fill.P1 289 DEC_fill.kappa1 DEC_fill.cx0_1 DEC_fill.cx1_1 :=
  Conv.nshift_of_foot (DEC_fill.cfoot1 clean hltC nltC itemsC tracedC cl) DEC_fill.chost1 (compact_a_eq DEC_fill.ckn01 DEC_fill.ckn11 DEC_fill.ckheap1 DEC_fill.ckpl1)

-- the observers: the layers' states at the call, the canonical and the merged state, their footprints and checks
noncomputable def DEC_fill.fxC_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s4.ffi).getD PTrie.nil
noncomputable def DEC_fill.krC_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s4.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofxC_1 : (Host.Ts.Sim.Full.freedOf DEC_fill.s4.ffi) = some DEC_fill.fxC_1
kernel_rfl DEC_fill.okrC_1 : (Host.Ts.Sim.Full.krecOf DEC_fill.s4.ffi) = some DEC_fill.krC_1
noncomputable def DEC_fill.fx0_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s6.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr0_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s6.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx0_1 : (Host.Ts.Sim.Full.freedOf DEC_fill.s6.ffi) = some DEC_fill.fx0_1
kernel_rfl DEC_fill.okr0_1 : (Host.Ts.Sim.Full.krecOf DEC_fill.s6.ffi) = some DEC_fill.kr0_1
noncomputable def DEC_fill.fx1_1 : PTrie Unit := (Host.Ts.Sim.Full.freedOf DEC_fill.s5.ffi).getD PTrie.nil
noncomputable def DEC_fill.kr1_1 : Host.Load.Layers.KRec := (Host.Ts.Sim.Full.krecOf DEC_fill.s5.ffi).getD Host.Load.Layers.KRec.empty
kernel_rfl DEC_fill.ofx1_1 : (Host.Ts.Sim.Full.freedOf DEC_fill.s5.ffi) = some DEC_fill.fx1_1
kernel_rfl DEC_fill.okr1_1 : (Host.Ts.Sim.Full.krecOf DEC_fill.s5.ffi) = some DEC_fill.kr1_1
kernel_rfl DEC_fill.ff01 : DEC_fill.fx0_1 = Stage.setAll DEC_fill.fxC_1 (DEC_fill.clo1.filterMap fun i => (DEC_fill.fx0_1.get i).map (i, ·))
kernel_rfl DEC_fill.ff11 : DEC_fill.fx1_1 = Stage.setAll DEC_fill.fxC_1 (DEC_fill.cwS1.filterMap fun i => (DEC_fill.fx1_1.get i).map (i, ·))
kernel_rfl DEC_fill.ffck1 : freedLB DEC_fill.kappa1 DEC_fill.cx0_1.mlx DEC_fill.fx0_1 DEC_fill.fx1_1 DEC_fill.clo1 = true
kernel_rfl DEC_fill.fkf01 : DEC_fill.kr0_1.flags = Stage.setAll DEC_fill.krC_1.flags (DEC_fill.clo1.filterMap fun i => (DEC_fill.kr0_1.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt01 : DEC_fill.kr0_1.targs = Stage.setAll DEC_fill.krC_1.targs (DEC_fill.clo1.filterMap fun i => (DEC_fill.kr0_1.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkf11 : DEC_fill.kr1_1.flags = Stage.setAll DEC_fill.krC_1.flags (DEC_fill.cwS1.filterMap fun i => (DEC_fill.kr1_1.flags.get i).map (i, ·))
kernel_rfl DEC_fill.fkt11 : DEC_fill.kr1_1.targs = Stage.setAll DEC_fill.krC_1.targs (DEC_fill.cwS1.filterMap fun i => (DEC_fill.kr1_1.targs.get i).map (i, ·))
kernel_rfl DEC_fill.fkck1 : krecLB DEC_fill.kappa1 289 DEC_fill.cx0_1.mlx DEC_fill.kr0_1 DEC_fill.kr1_1 DEC_fill.clo1 = true
kernel_rfl DEC_fill.fkn1 : Nat.ble 129 289 = true
-- the bridge and the pending traces' regions
kernel_rfl DEC_fill.cbridge1 : Host.Ts.Sim.Full.bridgeOf DEC_fill.s5.ffi = Host.Ts.Sim.Full.bridgeOf DEC_fill.s6.ffi
kernel_rfl DEC_fill.cpendR1 : pendRegB DEC_fill.kappa1 (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx = true
kernel_rfl DEC_fill.cpendLe1 : Nat.ble (Host.Load.Layers.toLoad DEC_fill.s6.ffi).mlx.next (Host.Load.Layers.toLoad DEC_fill.s5.ffi).mlx.next = true
/-- **The compaction's native shift**, given the call's bookkeeping, its relation's facts (the model's and the
observers') and the canonical closedness. -/
theorem DEC_fill.cshift1 (clean : Conv.NClean (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt) (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx) (hltC : ∀ h, PH (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx h → h < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.next) (nltC : ∀ i, PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx i → i < (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.nnext) (itemsC : ∀ k v, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.items.get k = some v → PN (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx k) (tracedC : ∀ h o, (Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h = some o → ∀ i ∈ objTraces o, i < DEC_fill.P1.NL) (cl : SSt (· < 289) DEC_fill.cx0_1.mlx)
    (hobjC : ∀ h, DEC_fill.fxC_1.get h = some () → ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h).isSome = true)
    (hfC : ∀ h, (DEC_fill.krC_1.flags.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h).isSome = true)
    (htC : ∀ h, (DEC_fill.krC_1.targs.get h).isSome = true → ((Host.Load.Layers.toLoad DEC_fill.s4.ffi).mlx.objs.get h).isSome = true)
    (hclC : ∀ h l, DEC_fill.krC_1.targs.get h = some l → Host.Ts.Sim.Full.STargs (· < (⟨29303, 22540, 3123641, 129⟩ : Conv.Cnt).n) l) :
    Conv.FullShiftQ DEC_fill.P1 289 DEC_fill.kappa1 DEC_fill.s6.ffi DEC_fill.s5.ffi :=
  ⟨DEC_fill.cnshift1 clean hltC nltC itemsC tracedC cl, DEC_fill.cqueue1, fun t ht => bSN_sound (List.all_eq_true.mp DEC_fill.ctokSupp1 t ht),
    DEC_fill.cbridge1,
    liveShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s5.ffi) (DEC_fill.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.ofx0_1 DEC_fill.ofx1_1 hobjC DEC_fill.ff01 DEC_fill.ff11 DEC_fill.ffck1,
    kernShift_foot (x0' := Host.Ts.Sim.Full.mlxOf DEC_fill.s6.ffi) (x1' := Host.Ts.Sim.Full.mlxOf DEC_fill.s5.ffi) (DEC_fill.cfoot1 clean hltC nltC itemsC tracedC cl) rfl DEC_fill.okr0_1 DEC_fill.okr1_1 (Nat.le_of_ble_eq_true DEC_fill.fkn1) hfC htC hclC
      DEC_fill.fkf01 DEC_fill.fkt01 DEC_fill.fkf11 DEC_fill.fkt11 DEC_fill.fkck1,
    pendReg_of rfl DEC_fill.cnh01 DEC_fill.cnh11 (Nat.le_of_ble_eq_true DEC_fill.cpendLe1) DEC_fill.cpendR1⟩

end Host.Load.Run.Tpl

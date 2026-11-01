import host.sim.compose.PostPath
import host.sim.template.a4pre_pl_ta.m.B11
import host.sim.template.a4pre_pl_ta.m.B10
import host.sim.template.a4pre_pl_ta.m.B14
import host.sim.template.a4pre_pl_ta.H26
import host.sim.template.a4pre_pl_ta.H27
import host.sim.template.a4pre_pl_ta.Len181
import host.sim.template.a4pre_pl_ta.Len182
import host.sim.template.a4pre_pl_ta.Tail
import host.sim.template.a4pre_pl_ta.TailSteps
import host.sim.template.a4pre_pl_ta.TailRest
import host.sim.template.a4pre_pl_ta.Endpoint
import host.sim.template.a4pre_pl_ta.SpreadData
import host.sim.template.BootEq
import host.sim.template.a4pre_pl_ta.H28
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.Ta
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa854 : PRE_pl_ta.S854.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S854.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live861 : isHalt PRE_pl_ta.s861.ctl = false
kernel_rfl br854_862 : bridgeOf PRE_pl_ta.s862.ffi = bridgeOf PRE_pl_ta.s854.ffi
kernel_rfl cnt854_862 : countersOkB PRE_pl_ta.s854 PRE_pl_ta.s862 = true
kernel_rfl oa862 : PRE_pl_ta.S862.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S862.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt862_863 : countersOkB PRE_pl_ta.s862 PRE_pl_ta.s863 = true
kernel_rfl oa863 : PRE_pl_ta.S863.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S863.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live869 : isHalt PRE_pl_ta.s869.ctl = false
kernel_rfl br863_870 : bridgeOf PRE_pl_ta.s870.ffi = bridgeOf PRE_pl_ta.s863.ffi
kernel_rfl cnt863_870 : countersOkB PRE_pl_ta.s863 PRE_pl_ta.s870 = true
kernel_rfl oa870 : PRE_pl_ta.S870.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S870.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt870_871 : countersOkB PRE_pl_ta.s870 PRE_pl_ta.s871 = true
kernel_rfl oa871 : PRE_pl_ta.S871.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S871.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live872 : isHalt PRE_pl_ta.s872.ctl = false
kernel_rfl br871_873 : bridgeOf PRE_pl_ta.s873.ffi = bridgeOf PRE_pl_ta.s871.ffi
kernel_rfl cnt871_873 : countersOkB PRE_pl_ta.s871 PRE_pl_ta.s873 = true
kernel_rfl oa873 : PRE_pl_ta.S873.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S873.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt873_874 : countersOkB PRE_pl_ta.s873 PRE_pl_ta.s874 = true
kernel_rfl oa874 : PRE_pl_ta.S874.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S874.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live881 : isHalt PRE_pl_ta.s881.ctl = false
kernel_rfl br874_882 : bridgeOf PRE_pl_ta.s882.ffi = bridgeOf PRE_pl_ta.s874.ffi
kernel_rfl cnt874_882 : countersOkB PRE_pl_ta.s874 PRE_pl_ta.s882 = true
kernel_rfl oa882 : PRE_pl_ta.S882.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S882.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt882_883 : countersOkB PRE_pl_ta.s882 PRE_pl_ta.s883 = true
kernel_rfl oa883 : PRE_pl_ta.S883.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S883.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live886 : isHalt PRE_pl_ta.s886.ctl = false
kernel_rfl br883_887 : bridgeOf PRE_pl_ta.s887.ffi = bridgeOf PRE_pl_ta.s883.ffi
kernel_rfl cnt883_887 : countersOkB PRE_pl_ta.s883 PRE_pl_ta.s887 = true
kernel_rfl oa887 : PRE_pl_ta.S887.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S887.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl cnt887_888 : countersOkB PRE_pl_ta.s887 PRE_pl_ta.s888 = true
kernel_rfl oa888 : PRE_pl_ta.S888.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S888.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live890 : isHalt PRE_pl_ta.s890.ctl = false
kernel_rfl br888_891 : bridgeOf PRE_pl_ta.s891.ffi = bridgeOf PRE_pl_ta.s888.ffi
kernel_rfl cnt888_891 : countersOkB PRE_pl_ta.s888 PRE_pl_ta.s891 = true
kernel_rfl oa891 : PRE_pl_ta.S891.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S891.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl lst891 : PRE_pl_ta.s891.stack = .e (.member kLength false) :: PRE_pl_ta.s891.stack.tail
kernel_rfl cnt891_892 : countersOkB PRE_pl_ta.s891 PRE_pl_ta.s892 = true
kernel_rfl oa892 : PRE_pl_ta.S892.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S892.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl live893 : isHalt PRE_pl_ta.s893.ctl = false
kernel_rfl br892_894 : bridgeOf PRE_pl_ta.s894.ffi = bridgeOf PRE_pl_ta.s892.ffi
kernel_rfl cnt892_894 : countersOkB PRE_pl_ta.s892 PRE_pl_ta.s894 = true
kernel_rfl oa894 : PRE_pl_ta.S894.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S894.oracle.length) PRE_pl_ta.S0.oracle
kernel_rfl lst894 : PRE_pl_ta.s894.stack = .e (.member kLength false) :: PRE_pl_ta.s894.stack.tail
kernel_rfl cnt894_895 : countersOkB PRE_pl_ta.s894 PRE_pl_ta.s895 = true
kernel_rfl oa895 : PRE_pl_ta.S895.oracle = List.drop (PRE_pl_ta.S0.oracle.length - PRE_pl_ta.S895.oracle.length) PRE_pl_ta.S0.oracle
boot_rfl accTail from PRE_pl_ta.s895 to PRE_pl_ta.s895 : PostOk.okR PRE_pl_ta.s895 PRE_pl_ta.S895 = true
kernel_rfl liveSp : isHalt PRE_pl_ta.spPre.ctl = false
kernel_rfl topSp : noRetBlock PRE_pl_ta.spOpen = true
kernel_rfl brSp : bridgeOf PRE_pl_ta.spOpen.ffi = bridgeOf PRE_pl_ta.s895.ffi
kernel_rfl cntSp : countersOkB PRE_pl_ta.s895 PRE_pl_ta.spOpen = true
kernel_rfl wFwd : wideP 2673435 = none
kernel_rfl openNoOr : PRE_pl_ta.spOpenSrv.oracle = []
kernel_rfl cntClose : countersOkB PRE_pl_ta.spOpen PRE_pl_ta.spAfter = true
kernel_rfl proto : Present PRE_pl_ta.spClose aArrayProto
theorem afterInactive : (bridgeOf PRE_pl_ta.spAfter.ffi).active = false := Host.Load.Boot.replay_active _
kernel_rfl topEnd : noRetBlock PRE_pl_ta.s896 = true
kernel_rfl brEnd : bridgeOf PRE_pl_ta.s896.ffi = bridgeOf PRE_pl_ta.spAfter.ffi
kernel_rfl cntEnd : countersOkB PRE_pl_ta.spAfter PRE_pl_ta.s896 = true

abbrev n11 : Nat := (((((((((((((((((((((((((nth? PRE_pl_ta.ks 854).getD 0) + ((nth? PRE_pl_ta.ks 855).getD 0)) + ((nth? PRE_pl_ta.ks 856).getD 0)) + ((nth? PRE_pl_ta.ks 857).getD 0)) + ((nth? PRE_pl_ta.ks 858).getD 0)) + ((nth? PRE_pl_ta.ks 859).getD 0)) + ((nth? PRE_pl_ta.ks 860).getD 0)) + 1) + 3) + ((((((((nth? PRE_pl_ta.ks 863).getD 0) + ((nth? PRE_pl_ta.ks 864).getD 0)) + ((nth? PRE_pl_ta.ks 865).getD 0)) + ((nth? PRE_pl_ta.ks 866).getD 0)) + ((nth? PRE_pl_ta.ks 867).getD 0)) + ((nth? PRE_pl_ta.ks 868).getD 0)) + 1)) + 3) + (((nth? PRE_pl_ta.ks 871).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_ta.ks 874).getD 0) + ((nth? PRE_pl_ta.ks 875).getD 0)) + ((nth? PRE_pl_ta.ks 876).getD 0)) + ((nth? PRE_pl_ta.ks 877).getD 0)) + ((nth? PRE_pl_ta.ks 878).getD 0)) + ((nth? PRE_pl_ta.ks 879).getD 0)) + ((nth? PRE_pl_ta.ks 880).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_ta.ks 883).getD 0) + ((nth? PRE_pl_ta.ks 884).getD 0)) + ((nth? PRE_pl_ta.ks 885).getD 0)) + 1)) + 3) + ((((nth? PRE_pl_ta.ks 888).getD 0) + ((nth? PRE_pl_ta.ks 889).getD 0)) + 1)) + 1) + (((nth? PRE_pl_ta.ks 892).getD 0) + 1)) + 1) + (33 + 1)) + 3) + PRE_pl_ta.restFuel)

theorem c11 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_ta.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_ta.s854 PRE_pl_ta.S854)) (withMem Tr (endCut NB T tk cap [2673435, PRE_pl_ta.cacheArray] PRE_pl_ta.s896 PRE_pl_ta.S896)) n11 :=
  (((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted854 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run854 PRE_pl_ta.run855) PRE_pl_ta.run856) PRE_pl_ta.run857) PRE_pl_ta.run858) PRE_pl_ta.run859) PRE_pl_ta.run860) PRE_pl_ta.accepted861 live861 PRE_pl_ta.b176.step PRE_pl_ta.b176.top (fun ν h => by rw [oa854]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br854_862 cnt854_862 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b176.parts PRE_pl_ta.b176.args_ok PRE_pl_ta.b176.sym PRE_pl_ta.b176.mlx PRE_pl_ta.b176.pay (by decide) PRE_pl_ta.b176.decode PRE_pl_ta.b176.pre PRE_pl_ta.b176.runS (fun ν h => by rw [oa862]; exact good_drop _ (hg ν h)) PRE_pl_ta.b176.inactive PRE_pl_ta.b176.bridge cnt862_863 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted863 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run863 PRE_pl_ta.run864) PRE_pl_ta.run865) PRE_pl_ta.run866) PRE_pl_ta.run867) PRE_pl_ta.run868) PRE_pl_ta.accepted869 live869 PRE_pl_ta.b177.step PRE_pl_ta.b177.top (fun ν h => by rw [oa863]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br863_870 cnt863_870 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b177.parts PRE_pl_ta.b177.args_ok PRE_pl_ta.b177.sym PRE_pl_ta.b177.mlx PRE_pl_ta.b177.pay (by decide) PRE_pl_ta.b177.decode PRE_pl_ta.b177.pre PRE_pl_ta.b177.runS (fun ν h => by rw [oa870]; exact good_drop _ (hg ν h)) PRE_pl_ta.b177.inactive PRE_pl_ta.b177.bridge cnt870_871 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted871 PRE_pl_ta.run871 PRE_pl_ta.accepted872 live872 PRE_pl_ta.b178.step PRE_pl_ta.b178.top (fun ν h => by rw [oa871]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br871_873 cnt871_873 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b178.parts PRE_pl_ta.b178.args_ok PRE_pl_ta.b178.sym PRE_pl_ta.b178.mlx PRE_pl_ta.b178.pay (by decide) PRE_pl_ta.b178.decode PRE_pl_ta.b178.pre PRE_pl_ta.b178.runS (fun ν h => by rw [oa873]; exact good_drop _ (hg ν h)) PRE_pl_ta.b178.inactive PRE_pl_ta.b178.bridge cnt873_874 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted874 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run874 PRE_pl_ta.run875) PRE_pl_ta.run876) PRE_pl_ta.run877) PRE_pl_ta.run878) PRE_pl_ta.run879) PRE_pl_ta.run880) PRE_pl_ta.accepted881 live881 PRE_pl_ta.b179.step PRE_pl_ta.b179.top (fun ν h => by rw [oa874]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br874_882 cnt874_882 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b179.parts PRE_pl_ta.b179.args_ok PRE_pl_ta.b179.sym PRE_pl_ta.b179.mlx PRE_pl_ta.b179.pay (by decide) PRE_pl_ta.b179.decode PRE_pl_ta.b179.pre PRE_pl_ta.b179.runS (fun ν h => by rw [oa882]; exact good_drop _ (hg ν h)) PRE_pl_ta.b179.inactive PRE_pl_ta.b179.bridge cnt882_883 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted883 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run883 PRE_pl_ta.run884) PRE_pl_ta.run885) PRE_pl_ta.accepted886 live886 PRE_pl_ta.b180.step PRE_pl_ta.b180.top (fun ν h => by rw [oa883]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br883_887 cnt883_887 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b180.parts PRE_pl_ta.b180.args_ok PRE_pl_ta.b180.sym PRE_pl_ta.b180.mlx PRE_pl_ta.b180.pay (by decide) PRE_pl_ta.b180.decode PRE_pl_ta.b180.pre PRE_pl_ta.b180.runS (fun ν h => by rw [oa887]; exact good_drop _ (hg ν h)) PRE_pl_ta.b180.inactive PRE_pl_ta.b180.bridge cnt887_888 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted888 (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_ta.run888 PRE_pl_ta.run889) PRE_pl_ta.accepted890 live890 PRE_pl_ta.b181.enter PRE_pl_ta.b181.top (fun ν h => by rw [oa888]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br888_891 cnt888_891 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b181.ctl lst891 PRE_pl_ta.b181.objGet PRE_pl_ta.b181.kind PRE_pl_ta.b181.patch (fun ν h => by rw [oa891]; exact good_drop _ (hg ν h)) PRE_pl_ta.b181.inactive PRE_pl_ta.b181.bridge cnt891_892 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_ta.accepted892 PRE_pl_ta.run892 PRE_pl_ta.accepted893 live893 PRE_pl_ta.b182.enter PRE_pl_ta.b182.top (fun ν h => by rw [oa892]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br892_894 cnt892_894 hT rfl)).trans (lenM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.b182.ctl lst894 PRE_pl_ta.b182.objGet PRE_pl_ta.b182.kind PRE_pl_ta.b182.patch (fun ν h => by rw [oa894]; exact good_drop _ (hg ν h)) PRE_pl_ta.b182.inactive PRE_pl_ta.b182.bridge cnt894_895 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (n := 33) (sb := PRE_pl_ta.spPre) (Sb := PRE_pl_ta.spPreSrv) (sc := PRE_pl_ta.spOpen) (Sc := PRE_pl_ta.spOpenSrv) (modeR NB T tk cap hcap) accTail (by have h := PRE_pl_ta.checkedTail; rw [← PRE_pl_ta.spreadStart, ← PRE_pl_ta.tailSrv] at h; exact h) PRE_pl_ta.acceptedSpPre liveSp PRE_pl_ta.spInto topSp (fun ν h => by rw [oa895]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) brSp cntSp hT rfl)).trans (spreadM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_ta.spCtl PRE_pl_ta.spStack PRE_pl_ta.spOpenStep PRE_pl_ta.spIdCtl PRE_pl_ta.spLookup PRE_pl_ta.spCellVal PRE_pl_ta.spCellNoW PRE_pl_ta.spIdStep PRE_pl_ta.spCloseCtl PRE_pl_ta.spCloseStack PRE_pl_ta.spFwd PRE_pl_ta.spFwdKind (by decide) wFwd PRE_pl_ta.spCloseStep PRE_pl_ta.spRoom proto PRE_pl_ta.spNewNoW openNoOr PRE_pl_ta.spAfterNoOracle PRE_pl_ta.spInactive PRE_pl_ta.spBridge cntClose hT)).trans (glueE (extra := [2673435, PRE_pl_ta.cacheArray]) (NB := NB) (T := T) (tk := tk) (cap := cap) hcap PRE_pl_ta.acceptedRest PRE_pl_ta.checkedRest topEnd PRE_pl_ta.spAfterNoOracle afterInactive brEnd cntEnd hT)

end Host.Ts.Sim.Compose.Post.PL.Ta

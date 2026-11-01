import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r1.Good
import host.sim.template.a4pre_pl_r1.K854
import host.sim.template.a4pre_pl_r1.K855
import host.sim.template.a4pre_pl_r1.K856
import host.sim.template.a4pre_pl_r1.K857
import host.sim.template.a4pre_pl_r1.K858
import host.sim.template.a4pre_pl_r1.K859
import host.sim.template.a4pre_pl_r1.K860
import host.sim.template.a4pre_pl_r1.Accept13
import host.sim.template.a4pre_pl_r1.Size176
import host.sim.template.a4pre_pl_r1.H26
import host.sim.template.a4pre_pl_r1.K863
import host.sim.template.a4pre_pl_r1.K864
import host.sim.template.a4pre_pl_r1.K865
import host.sim.template.a4pre_pl_r1.K866
import host.sim.template.a4pre_pl_r1.K867
import host.sim.template.a4pre_pl_r1.K868
import host.sim.template.a4pre_pl_r1.Size177
import host.sim.template.a4pre_pl_r1.H27
import host.sim.template.a4pre_pl_r1.K871
import host.sim.template.a4pre_pl_r1.Size178
import host.sim.template.a4pre_pl_r1.K874
import host.sim.template.a4pre_pl_r1.K875
import host.sim.template.a4pre_pl_r1.K876
import host.sim.template.a4pre_pl_r1.K877
import host.sim.template.a4pre_pl_r1.K878
import host.sim.template.a4pre_pl_r1.K879
import host.sim.template.a4pre_pl_r1.K880
import host.sim.template.a4pre_pl_r1.Accept14
import host.sim.template.a4pre_pl_r1.Size179
import host.sim.template.a4pre_pl_r1.K883
import host.sim.template.a4pre_pl_r1.K884
import host.sim.template.a4pre_pl_r1.K885
import host.sim.template.a4pre_pl_r1.Size180
import host.sim.template.a4pre_pl_r1.K888
import host.sim.template.a4pre_pl_r1.K889
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa854 : PRE_pl_r1.S854.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S854.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live861 : isHalt PRE_pl_r1.s861.ctl = false
kernel_rfl br854_862 : bridgeOf PRE_pl_r1.s862.ffi = bridgeOf PRE_pl_r1.s854.ffi
kernel_rfl cnt854_862 : countersOkB PRE_pl_r1.s854 PRE_pl_r1.s862 = true
kernel_rfl oa862 : PRE_pl_r1.S862.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S862.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt862_863 : countersOkB PRE_pl_r1.s862 PRE_pl_r1.s863 = true
kernel_rfl oa863 : PRE_pl_r1.S863.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S863.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live869 : isHalt PRE_pl_r1.s869.ctl = false
kernel_rfl br863_870 : bridgeOf PRE_pl_r1.s870.ffi = bridgeOf PRE_pl_r1.s863.ffi
kernel_rfl cnt863_870 : countersOkB PRE_pl_r1.s863 PRE_pl_r1.s870 = true
kernel_rfl oa870 : PRE_pl_r1.S870.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S870.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt870_871 : countersOkB PRE_pl_r1.s870 PRE_pl_r1.s871 = true
kernel_rfl oa871 : PRE_pl_r1.S871.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S871.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live872 : isHalt PRE_pl_r1.s872.ctl = false
kernel_rfl br871_873 : bridgeOf PRE_pl_r1.s873.ffi = bridgeOf PRE_pl_r1.s871.ffi
kernel_rfl cnt871_873 : countersOkB PRE_pl_r1.s871 PRE_pl_r1.s873 = true
kernel_rfl oa873 : PRE_pl_r1.S873.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S873.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt873_874 : countersOkB PRE_pl_r1.s873 PRE_pl_r1.s874 = true
kernel_rfl oa874 : PRE_pl_r1.S874.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S874.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live881 : isHalt PRE_pl_r1.s881.ctl = false
kernel_rfl br874_882 : bridgeOf PRE_pl_r1.s882.ffi = bridgeOf PRE_pl_r1.s874.ffi
kernel_rfl cnt874_882 : countersOkB PRE_pl_r1.s874 PRE_pl_r1.s882 = true
kernel_rfl oa882 : PRE_pl_r1.S882.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S882.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt882_883 : countersOkB PRE_pl_r1.s882 PRE_pl_r1.s883 = true
kernel_rfl oa883 : PRE_pl_r1.S883.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S883.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live886 : isHalt PRE_pl_r1.s886.ctl = false
kernel_rfl br883_887 : bridgeOf PRE_pl_r1.s887.ffi = bridgeOf PRE_pl_r1.s883.ffi
kernel_rfl cnt883_887 : countersOkB PRE_pl_r1.s883 PRE_pl_r1.s887 = true
kernel_rfl oa887 : PRE_pl_r1.S887.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S887.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt887_888 : countersOkB PRE_pl_r1.s887 PRE_pl_r1.s888 = true
kernel_rfl oa888 : PRE_pl_r1.S888.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S888.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl top890 : noRetBlock PRE_pl_r1.s890 = true
kernel_rfl br888_890 : bridgeOf PRE_pl_r1.s890.ffi = bridgeOf PRE_pl_r1.s888.ffi
kernel_rfl cnt888_890 : countersOkB PRE_pl_r1.s888 PRE_pl_r1.s890 = true

abbrev n11 : Nat := (((((((((((((((((((nth? PRE_pl_r1.ks 854).getD 0) + ((nth? PRE_pl_r1.ks 855).getD 0)) + ((nth? PRE_pl_r1.ks 856).getD 0)) + ((nth? PRE_pl_r1.ks 857).getD 0)) + ((nth? PRE_pl_r1.ks 858).getD 0)) + ((nth? PRE_pl_r1.ks 859).getD 0)) + ((nth? PRE_pl_r1.ks 860).getD 0)) + 1) + 3) + ((((((((nth? PRE_pl_r1.ks 863).getD 0) + ((nth? PRE_pl_r1.ks 864).getD 0)) + ((nth? PRE_pl_r1.ks 865).getD 0)) + ((nth? PRE_pl_r1.ks 866).getD 0)) + ((nth? PRE_pl_r1.ks 867).getD 0)) + ((nth? PRE_pl_r1.ks 868).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 871).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r1.ks 874).getD 0) + ((nth? PRE_pl_r1.ks 875).getD 0)) + ((nth? PRE_pl_r1.ks 876).getD 0)) + ((nth? PRE_pl_r1.ks 877).getD 0)) + ((nth? PRE_pl_r1.ks 878).getD 0)) + ((nth? PRE_pl_r1.ks 879).getD 0)) + ((nth? PRE_pl_r1.ks 880).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 883).getD 0) + ((nth? PRE_pl_r1.ks 884).getD 0)) + ((nth? PRE_pl_r1.ks 885).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 888).getD 0) + ((nth? PRE_pl_r1.ks 889).getD 0)))

theorem c11 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s854 PRE_pl_r1.S854)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s890 PRE_pl_r1.S890)) n11 :=
  (((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted854 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run854 PRE_pl_r1.run855) PRE_pl_r1.run856) PRE_pl_r1.run857) PRE_pl_r1.run858) PRE_pl_r1.run859) PRE_pl_r1.run860) PRE_pl_r1.accepted861 live861 PRE_pl_r1.b176.step PRE_pl_r1.b176.top (fun ν h => by rw [oa854]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br854_862 cnt854_862 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b176.parts PRE_pl_r1.b176.args_ok PRE_pl_r1.b176.sym PRE_pl_r1.b176.mlx PRE_pl_r1.b176.pay (by decide) PRE_pl_r1.b176.decode PRE_pl_r1.b176.pre PRE_pl_r1.b176.runS (fun ν h => by rw [oa862]; exact good_drop _ (hg ν h)) PRE_pl_r1.b176.inactive PRE_pl_r1.b176.bridge cnt862_863 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted863 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run863 PRE_pl_r1.run864) PRE_pl_r1.run865) PRE_pl_r1.run866) PRE_pl_r1.run867) PRE_pl_r1.run868) PRE_pl_r1.accepted869 live869 PRE_pl_r1.b177.step PRE_pl_r1.b177.top (fun ν h => by rw [oa863]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br863_870 cnt863_870 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b177.parts PRE_pl_r1.b177.args_ok PRE_pl_r1.b177.sym PRE_pl_r1.b177.mlx PRE_pl_r1.b177.pay (by decide) PRE_pl_r1.b177.decode PRE_pl_r1.b177.pre PRE_pl_r1.b177.runS (fun ν h => by rw [oa870]; exact good_drop _ (hg ν h)) PRE_pl_r1.b177.inactive PRE_pl_r1.b177.bridge cnt870_871 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted871 PRE_pl_r1.run871 PRE_pl_r1.accepted872 live872 PRE_pl_r1.b178.step PRE_pl_r1.b178.top (fun ν h => by rw [oa871]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br871_873 cnt871_873 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b178.parts PRE_pl_r1.b178.args_ok PRE_pl_r1.b178.sym PRE_pl_r1.b178.mlx PRE_pl_r1.b178.pay (by decide) PRE_pl_r1.b178.decode PRE_pl_r1.b178.pre PRE_pl_r1.b178.runS (fun ν h => by rw [oa873]; exact good_drop _ (hg ν h)) PRE_pl_r1.b178.inactive PRE_pl_r1.b178.bridge cnt873_874 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted874 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run874 PRE_pl_r1.run875) PRE_pl_r1.run876) PRE_pl_r1.run877) PRE_pl_r1.run878) PRE_pl_r1.run879) PRE_pl_r1.run880) PRE_pl_r1.accepted881 live881 PRE_pl_r1.b179.step PRE_pl_r1.b179.top (fun ν h => by rw [oa874]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br874_882 cnt874_882 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b179.parts PRE_pl_r1.b179.args_ok PRE_pl_r1.b179.sym PRE_pl_r1.b179.mlx PRE_pl_r1.b179.pay (by decide) PRE_pl_r1.b179.decode PRE_pl_r1.b179.pre PRE_pl_r1.b179.runS (fun ν h => by rw [oa882]; exact good_drop _ (hg ν h)) PRE_pl_r1.b179.inactive PRE_pl_r1.b179.bridge cnt882_883 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted883 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run883 PRE_pl_r1.run884) PRE_pl_r1.run885) PRE_pl_r1.accepted886 live886 PRE_pl_r1.b180.step PRE_pl_r1.b180.top (fun ν h => by rw [oa883]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br883_887 cnt883_887 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b180.parts PRE_pl_r1.b180.args_ok PRE_pl_r1.b180.sym PRE_pl_r1.b180.mlx PRE_pl_r1.b180.pay (by decide) PRE_pl_r1.b180.decode PRE_pl_r1.b180.pre PRE_pl_r1.b180.runS (fun ν h => by rw [oa887]; exact good_drop _ (hg ν h)) PRE_pl_r1.b180.inactive PRE_pl_r1.b180.bridge cnt887_888 hT)).trans (glueM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted888 (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run888 PRE_pl_r1.run889) top890 (fun ν h => by rw [oa888]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br888_890 cnt888_890 hT rfl)

end Host.Ts.Sim.Compose.Post.PL.R1

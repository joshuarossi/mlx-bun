import host.sim.compose.PostChain
import host.sim.template.a4pre_pl_r1.Good
import host.sim.template.a4pre_pl_r1.K87
import host.sim.template.a4pre_pl_r1.K88
import host.sim.template.a4pre_pl_r1.K89
import host.sim.template.a4pre_pl_r1.K90
import host.sim.template.a4pre_pl_r1.K91
import host.sim.template.a4pre_pl_r1.K92
import host.sim.template.a4pre_pl_r1.K93
import host.sim.template.a4pre_pl_r1.Accept1
import host.sim.template.a4pre_pl_r1.Size16
import host.sim.template.a4pre_pl_r1.H2
import host.sim.template.a4pre_pl_r1.H3
import host.sim.template.a4pre_pl_r1.K96
import host.sim.template.a4pre_pl_r1.K97
import host.sim.template.a4pre_pl_r1.K98
import host.sim.template.a4pre_pl_r1.Size17
import host.sim.template.a4pre_pl_r1.K101
import host.sim.template.a4pre_pl_r1.Size18
import host.sim.template.a4pre_pl_r1.K104
import host.sim.template.a4pre_pl_r1.K105
import host.sim.template.a4pre_pl_r1.K106
import host.sim.template.a4pre_pl_r1.K107
import host.sim.template.a4pre_pl_r1.Size19
import host.sim.template.a4pre_pl_r1.K110
import host.sim.template.a4pre_pl_r1.Size20
import host.sim.template.a4pre_pl_r1.K113
import host.sim.template.a4pre_pl_r1.K114
import host.sim.template.a4pre_pl_r1.K115
import host.sim.template.a4pre_pl_r1.Size21
import host.sim.template.a4pre_pl_r1.K118
import host.sim.template.a4pre_pl_r1.Size22
import host.sim.template.a4pre_pl_r1.K121
import host.sim.template.a4pre_pl_r1.K122
import host.sim.template.a4pre_pl_r1.K123
import host.sim.template.a4pre_pl_r1.K124
import host.sim.template.a4pre_pl_r1.Accept2
import host.sim.template.a4pre_pl_r1.Size23
import host.sim.template.a4pre_pl_r1.K127
import host.sim.template.a4pre_pl_r1.Size24
import host.sim.template.a4pre_pl_r1.H4
import host.sim.template.a4pre_pl_r1.K130
import host.sim.template.a4pre_pl_r1.K131
import host.sim.template.a4pre_pl_r1.K132
import host.sim.template.a4pre_pl_r1.Size25
import host.sim.template.a4pre_pl_r1.K135
import host.sim.template.a4pre_pl_r1.Size26
import host.sim.template.a4pre_pl_r1.K138
import host.sim.template.a4pre_pl_r1.K139
import host.sim.template.a4pre_pl_r1.K140
import host.sim.template.a4pre_pl_r1.K141
import host.sim.template.a4pre_pl_r1.Size27
import host.sim.template.a4pre_pl_r1.K144
import host.sim.template.a4pre_pl_r1.Size28
import host.sim.template.a4pre_pl_r1.K147
import host.sim.template.a4pre_pl_r1.K148
import host.sim.template.a4pre_pl_r1.K149
import host.sim.template.a4pre_pl_r1.K150
import host.sim.template.a4pre_pl_r1.K151
import host.sim.template.a4pre_pl_r1.K152
import host.sim.template.a4pre_pl_r1.K153
import host.sim.template.a4pre_pl_r1.Size29
import host.sim.template.a4pre_pl_r1.K156
import host.sim.template.a4pre_pl_r1.K157
import host.sim.template.a4pre_pl_r1.K158
import host.sim.template.a4pre_pl_r1.Size30
import host.sim.template.a4pre_pl_r1.H5
import host.sim.template.a4pre_pl_r1.K161
import host.sim.template.a4pre_pl_r1.Size31
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Sim.Compose.Post.PL.R1
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Prefill Host.Ts.Sim.Template Host.Load.Run.Tpl
open Host.Ts.Sim.Compose Host.Ts.Sim.Compose.Post

kernel_rfl oa87 : PRE_pl_r1.S87.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S87.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live94 : isHalt PRE_pl_r1.s94.ctl = false
kernel_rfl br87_95 : bridgeOf PRE_pl_r1.s95.ffi = bridgeOf PRE_pl_r1.s87.ffi
kernel_rfl cnt87_95 : countersOkB PRE_pl_r1.s87 PRE_pl_r1.s95 = true
kernel_rfl oa95 : PRE_pl_r1.S95.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S95.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt95_96 : countersOkB PRE_pl_r1.s95 PRE_pl_r1.s96 = true
kernel_rfl oa96 : PRE_pl_r1.S96.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S96.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live99 : isHalt PRE_pl_r1.s99.ctl = false
kernel_rfl br96_100 : bridgeOf PRE_pl_r1.s100.ffi = bridgeOf PRE_pl_r1.s96.ffi
kernel_rfl cnt96_100 : countersOkB PRE_pl_r1.s96 PRE_pl_r1.s100 = true
kernel_rfl oa100 : PRE_pl_r1.S100.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S100.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt100_101 : countersOkB PRE_pl_r1.s100 PRE_pl_r1.s101 = true
kernel_rfl oa101 : PRE_pl_r1.S101.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S101.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live102 : isHalt PRE_pl_r1.s102.ctl = false
kernel_rfl br101_103 : bridgeOf PRE_pl_r1.s103.ffi = bridgeOf PRE_pl_r1.s101.ffi
kernel_rfl cnt101_103 : countersOkB PRE_pl_r1.s101 PRE_pl_r1.s103 = true
kernel_rfl oa103 : PRE_pl_r1.S103.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S103.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt103_104 : countersOkB PRE_pl_r1.s103 PRE_pl_r1.s104 = true
kernel_rfl oa104 : PRE_pl_r1.S104.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S104.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live108 : isHalt PRE_pl_r1.s108.ctl = false
kernel_rfl br104_109 : bridgeOf PRE_pl_r1.s109.ffi = bridgeOf PRE_pl_r1.s104.ffi
kernel_rfl cnt104_109 : countersOkB PRE_pl_r1.s104 PRE_pl_r1.s109 = true
kernel_rfl oa109 : PRE_pl_r1.S109.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S109.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt109_110 : countersOkB PRE_pl_r1.s109 PRE_pl_r1.s110 = true
kernel_rfl oa110 : PRE_pl_r1.S110.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S110.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live111 : isHalt PRE_pl_r1.s111.ctl = false
kernel_rfl br110_112 : bridgeOf PRE_pl_r1.s112.ffi = bridgeOf PRE_pl_r1.s110.ffi
kernel_rfl cnt110_112 : countersOkB PRE_pl_r1.s110 PRE_pl_r1.s112 = true
kernel_rfl oa112 : PRE_pl_r1.S112.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S112.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt112_113 : countersOkB PRE_pl_r1.s112 PRE_pl_r1.s113 = true
kernel_rfl oa113 : PRE_pl_r1.S113.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S113.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live116 : isHalt PRE_pl_r1.s116.ctl = false
kernel_rfl br113_117 : bridgeOf PRE_pl_r1.s117.ffi = bridgeOf PRE_pl_r1.s113.ffi
kernel_rfl cnt113_117 : countersOkB PRE_pl_r1.s113 PRE_pl_r1.s117 = true
kernel_rfl oa117 : PRE_pl_r1.S117.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S117.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt117_118 : countersOkB PRE_pl_r1.s117 PRE_pl_r1.s118 = true
kernel_rfl oa118 : PRE_pl_r1.S118.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S118.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live119 : isHalt PRE_pl_r1.s119.ctl = false
kernel_rfl br118_120 : bridgeOf PRE_pl_r1.s120.ffi = bridgeOf PRE_pl_r1.s118.ffi
kernel_rfl cnt118_120 : countersOkB PRE_pl_r1.s118 PRE_pl_r1.s120 = true
kernel_rfl oa120 : PRE_pl_r1.S120.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S120.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt120_121 : countersOkB PRE_pl_r1.s120 PRE_pl_r1.s121 = true
kernel_rfl oa121 : PRE_pl_r1.S121.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S121.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live125 : isHalt PRE_pl_r1.s125.ctl = false
kernel_rfl br121_126 : bridgeOf PRE_pl_r1.s126.ffi = bridgeOf PRE_pl_r1.s121.ffi
kernel_rfl cnt121_126 : countersOkB PRE_pl_r1.s121 PRE_pl_r1.s126 = true
kernel_rfl oa126 : PRE_pl_r1.S126.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S126.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt126_127 : countersOkB PRE_pl_r1.s126 PRE_pl_r1.s127 = true
kernel_rfl oa127 : PRE_pl_r1.S127.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S127.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live128 : isHalt PRE_pl_r1.s128.ctl = false
kernel_rfl br127_129 : bridgeOf PRE_pl_r1.s129.ffi = bridgeOf PRE_pl_r1.s127.ffi
kernel_rfl cnt127_129 : countersOkB PRE_pl_r1.s127 PRE_pl_r1.s129 = true
kernel_rfl oa129 : PRE_pl_r1.S129.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S129.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt129_130 : countersOkB PRE_pl_r1.s129 PRE_pl_r1.s130 = true
kernel_rfl oa130 : PRE_pl_r1.S130.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S130.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live133 : isHalt PRE_pl_r1.s133.ctl = false
kernel_rfl br130_134 : bridgeOf PRE_pl_r1.s134.ffi = bridgeOf PRE_pl_r1.s130.ffi
kernel_rfl cnt130_134 : countersOkB PRE_pl_r1.s130 PRE_pl_r1.s134 = true
kernel_rfl oa134 : PRE_pl_r1.S134.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S134.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt134_135 : countersOkB PRE_pl_r1.s134 PRE_pl_r1.s135 = true
kernel_rfl oa135 : PRE_pl_r1.S135.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S135.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live136 : isHalt PRE_pl_r1.s136.ctl = false
kernel_rfl br135_137 : bridgeOf PRE_pl_r1.s137.ffi = bridgeOf PRE_pl_r1.s135.ffi
kernel_rfl cnt135_137 : countersOkB PRE_pl_r1.s135 PRE_pl_r1.s137 = true
kernel_rfl oa137 : PRE_pl_r1.S137.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S137.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt137_138 : countersOkB PRE_pl_r1.s137 PRE_pl_r1.s138 = true
kernel_rfl oa138 : PRE_pl_r1.S138.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S138.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live142 : isHalt PRE_pl_r1.s142.ctl = false
kernel_rfl br138_143 : bridgeOf PRE_pl_r1.s143.ffi = bridgeOf PRE_pl_r1.s138.ffi
kernel_rfl cnt138_143 : countersOkB PRE_pl_r1.s138 PRE_pl_r1.s143 = true
kernel_rfl oa143 : PRE_pl_r1.S143.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S143.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt143_144 : countersOkB PRE_pl_r1.s143 PRE_pl_r1.s144 = true
kernel_rfl oa144 : PRE_pl_r1.S144.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S144.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live145 : isHalt PRE_pl_r1.s145.ctl = false
kernel_rfl br144_146 : bridgeOf PRE_pl_r1.s146.ffi = bridgeOf PRE_pl_r1.s144.ffi
kernel_rfl cnt144_146 : countersOkB PRE_pl_r1.s144 PRE_pl_r1.s146 = true
kernel_rfl oa146 : PRE_pl_r1.S146.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S146.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt146_147 : countersOkB PRE_pl_r1.s146 PRE_pl_r1.s147 = true
kernel_rfl oa147 : PRE_pl_r1.S147.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S147.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live154 : isHalt PRE_pl_r1.s154.ctl = false
kernel_rfl br147_155 : bridgeOf PRE_pl_r1.s155.ffi = bridgeOf PRE_pl_r1.s147.ffi
kernel_rfl cnt147_155 : countersOkB PRE_pl_r1.s147 PRE_pl_r1.s155 = true
kernel_rfl oa155 : PRE_pl_r1.S155.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S155.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt155_156 : countersOkB PRE_pl_r1.s155 PRE_pl_r1.s156 = true
kernel_rfl oa156 : PRE_pl_r1.S156.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S156.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live159 : isHalt PRE_pl_r1.s159.ctl = false
kernel_rfl br156_160 : bridgeOf PRE_pl_r1.s160.ffi = bridgeOf PRE_pl_r1.s156.ffi
kernel_rfl cnt156_160 : countersOkB PRE_pl_r1.s156 PRE_pl_r1.s160 = true
kernel_rfl oa160 : PRE_pl_r1.S160.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S160.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt160_161 : countersOkB PRE_pl_r1.s160 PRE_pl_r1.s161 = true
kernel_rfl oa161 : PRE_pl_r1.S161.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S161.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl live162 : isHalt PRE_pl_r1.s162.ctl = false
kernel_rfl br161_163 : bridgeOf PRE_pl_r1.s163.ffi = bridgeOf PRE_pl_r1.s161.ffi
kernel_rfl cnt161_163 : countersOkB PRE_pl_r1.s161 PRE_pl_r1.s163 = true
kernel_rfl oa163 : PRE_pl_r1.S163.oracle = List.drop (PRE_pl_r1.S0.oracle.length - PRE_pl_r1.S163.oracle.length) PRE_pl_r1.S0.oracle
kernel_rfl cnt163_164 : countersOkB PRE_pl_r1.s163 PRE_pl_r1.s164 = true

abbrev n1 : Nat := ((((((((((((((((((((((((((((((((((((((((nth? PRE_pl_r1.ks 87).getD 0) + ((nth? PRE_pl_r1.ks 88).getD 0)) + ((nth? PRE_pl_r1.ks 89).getD 0)) + ((nth? PRE_pl_r1.ks 90).getD 0)) + ((nth? PRE_pl_r1.ks 91).getD 0)) + ((nth? PRE_pl_r1.ks 92).getD 0)) + ((nth? PRE_pl_r1.ks 93).getD 0)) + 1) + 3) + (((((nth? PRE_pl_r1.ks 96).getD 0) + ((nth? PRE_pl_r1.ks 97).getD 0)) + ((nth? PRE_pl_r1.ks 98).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 101).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 104).getD 0) + ((nth? PRE_pl_r1.ks 105).getD 0)) + ((nth? PRE_pl_r1.ks 106).getD 0)) + ((nth? PRE_pl_r1.ks 107).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 110).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 113).getD 0) + ((nth? PRE_pl_r1.ks 114).getD 0)) + ((nth? PRE_pl_r1.ks 115).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 118).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 121).getD 0) + ((nth? PRE_pl_r1.ks 122).getD 0)) + ((nth? PRE_pl_r1.ks 123).getD 0)) + ((nth? PRE_pl_r1.ks 124).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 127).getD 0) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 130).getD 0) + ((nth? PRE_pl_r1.ks 131).getD 0)) + ((nth? PRE_pl_r1.ks 132).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 135).getD 0) + 1)) + 3) + ((((((nth? PRE_pl_r1.ks 138).getD 0) + ((nth? PRE_pl_r1.ks 139).getD 0)) + ((nth? PRE_pl_r1.ks 140).getD 0)) + ((nth? PRE_pl_r1.ks 141).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 144).getD 0) + 1)) + 3) + (((((((((nth? PRE_pl_r1.ks 147).getD 0) + ((nth? PRE_pl_r1.ks 148).getD 0)) + ((nth? PRE_pl_r1.ks 149).getD 0)) + ((nth? PRE_pl_r1.ks 150).getD 0)) + ((nth? PRE_pl_r1.ks 151).getD 0)) + ((nth? PRE_pl_r1.ks 152).getD 0)) + ((nth? PRE_pl_r1.ks 153).getD 0)) + 1)) + 3) + (((((nth? PRE_pl_r1.ks 156).getD 0) + ((nth? PRE_pl_r1.ks 157).getD 0)) + ((nth? PRE_pl_r1.ks 158).getD 0)) + 1)) + 3) + (((nth? PRE_pl_r1.ks 161).getD 0) + 1)) + 3)

theorem c1 (NB T : Nat) (tk : Nat → Nat) (cap nI : Nat) (π : List Nat) (hcap : cap ≤ 4096 + 1593835520) (hg : ∀ ν, BookV T tk π.length ν → Good ν PRE_pl_r1.S0.oracle) (Tr : SegInst FF → Prop) (hT : ∀ x y, NTrack x y → Tr x → Tr y) :
    CutStep (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s87 PRE_pl_r1.S87)) (withMem Tr (indexedCut NB T tk cap nI π PRE_pl_r1.s164 PRE_pl_r1.S164)) n1 :=
  ((((((((((((((((((((((((((((((((callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted87 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run87 PRE_pl_r1.run88) PRE_pl_r1.run89) PRE_pl_r1.run90) PRE_pl_r1.run91) PRE_pl_r1.run92) PRE_pl_r1.run93) PRE_pl_r1.accepted94 live94 PRE_pl_r1.b16.step PRE_pl_r1.b16.top (fun ν h => by rw [oa87]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br87_95 cnt87_95 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b16.parts PRE_pl_r1.b16.args_ok PRE_pl_r1.b16.sym PRE_pl_r1.b16.mlx PRE_pl_r1.b16.pay (by decide) PRE_pl_r1.b16.decode PRE_pl_r1.b16.pre PRE_pl_r1.b16.runS (fun ν h => by rw [oa95]; exact good_drop _ (hg ν h)) PRE_pl_r1.b16.inactive PRE_pl_r1.b16.bridge cnt95_96 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted96 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run96 PRE_pl_r1.run97) PRE_pl_r1.run98) PRE_pl_r1.accepted99 live99 PRE_pl_r1.b17.step PRE_pl_r1.b17.top (fun ν h => by rw [oa96]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br96_100 cnt96_100 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b17.parts PRE_pl_r1.b17.args_ok PRE_pl_r1.b17.sym PRE_pl_r1.b17.mlx PRE_pl_r1.b17.pay (by decide) PRE_pl_r1.b17.decode PRE_pl_r1.b17.pre PRE_pl_r1.b17.runS (fun ν h => by rw [oa100]; exact good_drop _ (hg ν h)) PRE_pl_r1.b17.inactive PRE_pl_r1.b17.bridge cnt100_101 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted101 PRE_pl_r1.run101 PRE_pl_r1.accepted102 live102 PRE_pl_r1.b18.step PRE_pl_r1.b18.top (fun ν h => by rw [oa101]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br101_103 cnt101_103 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b18.parts PRE_pl_r1.b18.args_ok PRE_pl_r1.b18.sym PRE_pl_r1.b18.mlx PRE_pl_r1.b18.pay (by decide) PRE_pl_r1.b18.decode PRE_pl_r1.b18.pre PRE_pl_r1.b18.runS (fun ν h => by rw [oa103]; exact good_drop _ (hg ν h)) PRE_pl_r1.b18.inactive PRE_pl_r1.b18.bridge cnt103_104 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted104 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run104 PRE_pl_r1.run105) PRE_pl_r1.run106) PRE_pl_r1.run107) PRE_pl_r1.accepted108 live108 PRE_pl_r1.b19.step PRE_pl_r1.b19.top (fun ν h => by rw [oa104]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br104_109 cnt104_109 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b19.parts PRE_pl_r1.b19.args_ok PRE_pl_r1.b19.sym PRE_pl_r1.b19.mlx PRE_pl_r1.b19.pay (by decide) PRE_pl_r1.b19.decode PRE_pl_r1.b19.pre PRE_pl_r1.b19.runS (fun ν h => by rw [oa109]; exact good_drop _ (hg ν h)) PRE_pl_r1.b19.inactive PRE_pl_r1.b19.bridge cnt109_110 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted110 PRE_pl_r1.run110 PRE_pl_r1.accepted111 live111 PRE_pl_r1.b20.step PRE_pl_r1.b20.top (fun ν h => by rw [oa110]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br110_112 cnt110_112 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b20.parts PRE_pl_r1.b20.args_ok PRE_pl_r1.b20.sym PRE_pl_r1.b20.mlx PRE_pl_r1.b20.pay (by decide) PRE_pl_r1.b20.decode PRE_pl_r1.b20.pre PRE_pl_r1.b20.runS (fun ν h => by rw [oa112]; exact good_drop _ (hg ν h)) PRE_pl_r1.b20.inactive PRE_pl_r1.b20.bridge cnt112_113 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted113 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run113 PRE_pl_r1.run114) PRE_pl_r1.run115) PRE_pl_r1.accepted116 live116 PRE_pl_r1.b21.step PRE_pl_r1.b21.top (fun ν h => by rw [oa113]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br113_117 cnt113_117 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b21.parts PRE_pl_r1.b21.args_ok PRE_pl_r1.b21.sym PRE_pl_r1.b21.mlx PRE_pl_r1.b21.pay (by decide) PRE_pl_r1.b21.decode PRE_pl_r1.b21.pre PRE_pl_r1.b21.runS (fun ν h => by rw [oa117]; exact good_drop _ (hg ν h)) PRE_pl_r1.b21.inactive PRE_pl_r1.b21.bridge cnt117_118 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted118 PRE_pl_r1.run118 PRE_pl_r1.accepted119 live119 PRE_pl_r1.b22.step PRE_pl_r1.b22.top (fun ν h => by rw [oa118]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br118_120 cnt118_120 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b22.parts PRE_pl_r1.b22.args_ok PRE_pl_r1.b22.sym PRE_pl_r1.b22.mlx PRE_pl_r1.b22.pay (by decide) PRE_pl_r1.b22.decode PRE_pl_r1.b22.pre PRE_pl_r1.b22.runS (fun ν h => by rw [oa120]; exact good_drop _ (hg ν h)) PRE_pl_r1.b22.inactive PRE_pl_r1.b22.bridge cnt120_121 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted121 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run121 PRE_pl_r1.run122) PRE_pl_r1.run123) PRE_pl_r1.run124) PRE_pl_r1.accepted125 live125 PRE_pl_r1.b23.step PRE_pl_r1.b23.top (fun ν h => by rw [oa121]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br121_126 cnt121_126 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b23.parts PRE_pl_r1.b23.args_ok PRE_pl_r1.b23.sym PRE_pl_r1.b23.mlx PRE_pl_r1.b23.pay (by decide) PRE_pl_r1.b23.decode PRE_pl_r1.b23.pre PRE_pl_r1.b23.runS (fun ν h => by rw [oa126]; exact good_drop _ (hg ν h)) PRE_pl_r1.b23.inactive PRE_pl_r1.b23.bridge cnt126_127 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted127 PRE_pl_r1.run127 PRE_pl_r1.accepted128 live128 PRE_pl_r1.b24.step PRE_pl_r1.b24.top (fun ν h => by rw [oa127]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br127_129 cnt127_129 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b24.parts PRE_pl_r1.b24.args_ok PRE_pl_r1.b24.sym PRE_pl_r1.b24.mlx PRE_pl_r1.b24.pay (by decide) PRE_pl_r1.b24.decode PRE_pl_r1.b24.pre PRE_pl_r1.b24.runS (fun ν h => by rw [oa129]; exact good_drop _ (hg ν h)) PRE_pl_r1.b24.inactive PRE_pl_r1.b24.bridge cnt129_130 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted130 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run130 PRE_pl_r1.run131) PRE_pl_r1.run132) PRE_pl_r1.accepted133 live133 PRE_pl_r1.b25.step PRE_pl_r1.b25.top (fun ν h => by rw [oa130]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br130_134 cnt130_134 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b25.parts PRE_pl_r1.b25.args_ok PRE_pl_r1.b25.sym PRE_pl_r1.b25.mlx PRE_pl_r1.b25.pay (by decide) PRE_pl_r1.b25.decode PRE_pl_r1.b25.pre PRE_pl_r1.b25.runS (fun ν h => by rw [oa134]; exact good_drop _ (hg ν h)) PRE_pl_r1.b25.inactive PRE_pl_r1.b25.bridge cnt134_135 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted135 PRE_pl_r1.run135 PRE_pl_r1.accepted136 live136 PRE_pl_r1.b26.step PRE_pl_r1.b26.top (fun ν h => by rw [oa135]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br135_137 cnt135_137 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b26.parts PRE_pl_r1.b26.args_ok PRE_pl_r1.b26.sym PRE_pl_r1.b26.mlx PRE_pl_r1.b26.pay (by decide) PRE_pl_r1.b26.decode PRE_pl_r1.b26.pre PRE_pl_r1.b26.runS (fun ν h => by rw [oa137]; exact good_drop _ (hg ν h)) PRE_pl_r1.b26.inactive PRE_pl_r1.b26.bridge cnt137_138 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted138 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run138 PRE_pl_r1.run139) PRE_pl_r1.run140) PRE_pl_r1.run141) PRE_pl_r1.accepted142 live142 PRE_pl_r1.b27.step PRE_pl_r1.b27.top (fun ν h => by rw [oa138]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br138_143 cnt138_143 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b27.parts PRE_pl_r1.b27.args_ok PRE_pl_r1.b27.sym PRE_pl_r1.b27.mlx PRE_pl_r1.b27.pay (by decide) PRE_pl_r1.b27.decode PRE_pl_r1.b27.pre PRE_pl_r1.b27.runS (fun ν h => by rw [oa143]; exact good_drop _ (hg ν h)) PRE_pl_r1.b27.inactive PRE_pl_r1.b27.bridge cnt143_144 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted144 PRE_pl_r1.run144 PRE_pl_r1.accepted145 live145 PRE_pl_r1.b28.step PRE_pl_r1.b28.top (fun ν h => by rw [oa144]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br144_146 cnt144_146 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b28.parts PRE_pl_r1.b28.args_ok PRE_pl_r1.b28.sym PRE_pl_r1.b28.mlx PRE_pl_r1.b28.pay (by decide) PRE_pl_r1.b28.decode PRE_pl_r1.b28.pre PRE_pl_r1.b28.runS (fun ν h => by rw [oa146]; exact good_drop _ (hg ν h)) PRE_pl_r1.b28.inactive PRE_pl_r1.b28.bridge cnt146_147 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted147 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run147 PRE_pl_r1.run148) PRE_pl_r1.run149) PRE_pl_r1.run150) PRE_pl_r1.run151) PRE_pl_r1.run152) PRE_pl_r1.run153) PRE_pl_r1.accepted154 live154 PRE_pl_r1.b29.step PRE_pl_r1.b29.top (fun ν h => by rw [oa147]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br147_155 cnt147_155 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b29.parts PRE_pl_r1.b29.args_ok PRE_pl_r1.b29.sym PRE_pl_r1.b29.mlx PRE_pl_r1.b29.pay (by decide) PRE_pl_r1.b29.decode PRE_pl_r1.b29.pre PRE_pl_r1.b29.runS (fun ν h => by rw [oa155]; exact good_drop _ (hg ν h)) PRE_pl_r1.b29.inactive PRE_pl_r1.b29.bridge cnt155_156 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted156 (runOk_trans FF _ _ _ _ _ _ _ _ _ (runOk_trans FF _ _ _ _ _ _ _ _ _ PRE_pl_r1.run156 PRE_pl_r1.run157) PRE_pl_r1.run158) PRE_pl_r1.accepted159 live159 PRE_pl_r1.b30.step PRE_pl_r1.b30.top (fun ν h => by rw [oa156]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br156_160 cnt156_160 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b30.parts PRE_pl_r1.b30.args_ok PRE_pl_r1.b30.sym PRE_pl_r1.b30.mlx PRE_pl_r1.b30.pay (by decide) PRE_pl_r1.b30.decode PRE_pl_r1.b30.pre PRE_pl_r1.b30.runS (fun ν h => by rw [oa160]; exact good_drop _ (hg ν h)) PRE_pl_r1.b30.inactive PRE_pl_r1.b30.bridge cnt160_161 hT)).trans (callM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) (modeR NB T tk cap hcap) PRE_pl_r1.accepted161 PRE_pl_r1.run161 PRE_pl_r1.accepted162 live162 PRE_pl_r1.b31.step PRE_pl_r1.b31.top (fun ν h => by rw [oa161]; exact good_drop _ (hg ν h)) (Host.Load.Boot.replay_active _) br161_163 cnt161_163 hT rfl)).trans (sizeM (NB := NB) (T := T) (tk := tk) (cap := cap) (nI := nI) (π := π) PRE_pl_r1.b31.parts PRE_pl_r1.b31.args_ok PRE_pl_r1.b31.sym PRE_pl_r1.b31.mlx PRE_pl_r1.b31.pay (by decide) PRE_pl_r1.b31.decode PRE_pl_r1.b31.pre PRE_pl_r1.b31.runS (fun ν h => by rw [oa163]; exact good_drop _ (hg ν h)) PRE_pl_r1.b31.inactive PRE_pl_r1.b31.bridge cnt163_164 hT)

end Host.Ts.Sim.Compose.Post.PL.R1

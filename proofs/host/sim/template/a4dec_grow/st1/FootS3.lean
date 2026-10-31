import host.sim.template.a4dec_grow.st1.FootS2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_grow.st1.fR96 : List (Nat × Nat) := [(2672610, 2672611), (3069612, 3069613), (3218604, 3218608), (3218833, 3218834), (3218899, 3218901)]
kernel_rfl DEC_grow.st1.fh96 : DEC_grow.st1.s97.heap = setAll DEC_grow.st1.s96.heap (rangesOf DEC_grow.st1.s97.heap DEC_grow.st1.fR96 ++ freshOf DEC_grow.st1.s97.heap DEC_grow.st1.s96.next DEC_grow.st1.s97.next)
kernel_rfl DEC_grow.st1.fb96 : footRB DEC_grow.st1.s96 DEC_grow.st1.s97 DEC_grow.st1.fR96 = true
kernel_rfl DEC_grow.st1.fc96 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s96.next && Nat.ble DEC_grow.st1.s97.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR96 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa97 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s97 :=
  DEC_grow.st1.fa96.step (stageFoot_ofRF DEC_grow.st1.fh96 DEC_grow.st1.fb96) (incl_of_footW DEC_grow.st1.fb96 DEC_grow.st1.fc96)

def DEC_grow.st1.fR97 : List (Nat × Nat) := [(2672610, 2672611), (3070041, 3070042), (3218560, 3218563), (3218608, 3218613), (3218802, 3218803), (3219027, 3219028), (3219113, 3219114), (3219202, 3219203), (3219245, 3219247), (3219568, 3219569), (3219574, 3219575), (3219580, 3219581), (3219699, 3219700), (3219900, 3219901)]
kernel_rfl DEC_grow.st1.fh97 : DEC_grow.st1.s98.heap = setAll DEC_grow.st1.s97.heap (rangesOf DEC_grow.st1.s98.heap DEC_grow.st1.fR97 ++ freshOf DEC_grow.st1.s98.heap DEC_grow.st1.s97.next DEC_grow.st1.s98.next)
kernel_rfl DEC_grow.st1.fb97 : footRB DEC_grow.st1.s97 DEC_grow.st1.s98 DEC_grow.st1.fR97 = true
kernel_rfl DEC_grow.st1.fc97 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s97.next && Nat.ble DEC_grow.st1.s98.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR97 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa98 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s98 :=
  DEC_grow.st1.fa97.step (stageFoot_ofRF DEC_grow.st1.fh97 DEC_grow.st1.fb97) (incl_of_footW DEC_grow.st1.fb97 DEC_grow.st1.fc97)

def DEC_grow.st1.fR98 : List (Nat × Nat) := [(3123795, 3123796), (3218500, 3218501), (3218588, 3218589), (3220202, 3220203), (3220256, 3220257), (3220262, 3220263), (3220268, 3220269), (3220522, 3220523), (3220543, 3220544), (3220593, 3220594), (3220612, 3220613), (3220755, 3220756), (3220833, 3220834)]
kernel_rfl DEC_grow.st1.fh98 : DEC_grow.st1.s99.heap = setAll DEC_grow.st1.s98.heap (rangesOf DEC_grow.st1.s99.heap DEC_grow.st1.fR98 ++ freshOf DEC_grow.st1.s99.heap DEC_grow.st1.s98.next DEC_grow.st1.s99.next)
kernel_rfl DEC_grow.st1.fb98 : footRB DEC_grow.st1.s98 DEC_grow.st1.s99 DEC_grow.st1.fR98 = true
kernel_rfl DEC_grow.st1.fc98 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s98.next && Nat.ble DEC_grow.st1.s99.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR98 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa99 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s99 :=
  DEC_grow.st1.fa98.step (stageFoot_ofRF DEC_grow.st1.fh98 DEC_grow.st1.fb98) (incl_of_footW DEC_grow.st1.fb98 DEC_grow.st1.fc98)

def DEC_grow.st1.fR99 : List (Nat × Nat) := [(2672615, 2672616), (3072004, 3072005), (3072433, 3072434), (3220952, 3220955), (3221000, 3221005), (3221194, 3221195), (3221419, 3221420), (3221505, 3221506), (3221594, 3221595), (3221632, 3221639), (3221679, 3221680), (3221732, 3221733), (3221903, 3221904)]
kernel_rfl DEC_grow.st1.fh99 : DEC_grow.st1.s100.heap = setAll DEC_grow.st1.s99.heap (rangesOf DEC_grow.st1.s100.heap DEC_grow.st1.fR99 ++ freshOf DEC_grow.st1.s100.heap DEC_grow.st1.s99.next DEC_grow.st1.s100.next)
kernel_rfl DEC_grow.st1.fb99 : footRB DEC_grow.st1.s99 DEC_grow.st1.s100 DEC_grow.st1.fR99 = true
kernel_rfl DEC_grow.st1.fc99 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s99.next && Nat.ble DEC_grow.st1.s100.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR99 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa100 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s100 :=
  DEC_grow.st1.fa99.step (stageFoot_ofRF DEC_grow.st1.fh99 DEC_grow.st1.fb99) (incl_of_footW DEC_grow.st1.fb99 DEC_grow.st1.fc99)

def DEC_grow.st1.fR100 : List (Nat × Nat) := [(3123795, 3123796), (3220914, 3220915), (3220980, 3220981), (3222594, 3222595), (3222648, 3222649), (3222654, 3222655), (3222660, 3222661), (3222668, 3222669), (3222681, 3222683), (3222737, 3222738), (3222765, 3222766), (3222768, 3222778), (3222839, 3222841)]
kernel_rfl DEC_grow.st1.fh100 : DEC_grow.st1.s101.heap = setAll DEC_grow.st1.s100.heap (rangesOf DEC_grow.st1.s101.heap DEC_grow.st1.fR100 ++ freshOf DEC_grow.st1.s101.heap DEC_grow.st1.s100.next DEC_grow.st1.s101.next)
kernel_rfl DEC_grow.st1.fb100 : footRB DEC_grow.st1.s100 DEC_grow.st1.s101 DEC_grow.st1.fR100 = true
kernel_rfl DEC_grow.st1.fc100 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s100.next && Nat.ble DEC_grow.st1.s101.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR100 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa101 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s101 :=
  DEC_grow.st1.fa100.step (stageFoot_ofRF DEC_grow.st1.fh100 DEC_grow.st1.fb100) (incl_of_footW DEC_grow.st1.fb100 DEC_grow.st1.fc100)

def DEC_grow.st1.fR101 : List (Nat × Nat) := [(2672620, 2672621), (3074396, 3074397), (3074825, 3074826), (3223388, 3223396), (3223586, 3223587), (3223775, 3223776), (3223803, 3223805), (3223806, 3223807)]
kernel_rfl DEC_grow.st1.fh101 : DEC_grow.st1.s102.heap = setAll DEC_grow.st1.s101.heap (rangesOf DEC_grow.st1.s102.heap DEC_grow.st1.fR101 ++ freshOf DEC_grow.st1.s102.heap DEC_grow.st1.s101.next DEC_grow.st1.s102.next)
kernel_rfl DEC_grow.st1.fb101 : footRB DEC_grow.st1.s101 DEC_grow.st1.s102 DEC_grow.st1.fR101 = true
kernel_rfl DEC_grow.st1.fc101 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s101.next && Nat.ble DEC_grow.st1.s102.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR101 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa102 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s102 :=
  DEC_grow.st1.fa101.step (stageFoot_ofRF DEC_grow.st1.fh101 DEC_grow.st1.fb101) (incl_of_footW DEC_grow.st1.fb101 DEC_grow.st1.fc101)

def DEC_grow.st1.fR102 : List (Nat × Nat) := [(3123795, 3123796), (3223306, 3223307), (3223344, 3223347), (3223372, 3223373), (3223396, 3223397), (3224803, 3224804)]
kernel_rfl DEC_grow.st1.fh102 : DEC_grow.st1.s103.heap = setAll DEC_grow.st1.s102.heap (rangesOf DEC_grow.st1.s103.heap DEC_grow.st1.fR102 ++ freshOf DEC_grow.st1.s103.heap DEC_grow.st1.s102.next DEC_grow.st1.s103.next)
kernel_rfl DEC_grow.st1.fb102 : footRB DEC_grow.st1.s102 DEC_grow.st1.s103 DEC_grow.st1.fR102 = true
kernel_rfl DEC_grow.st1.fc102 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s102.next && Nat.ble DEC_grow.st1.s103.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR102 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa103 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s103 :=
  DEC_grow.st1.fa102.step (stageFoot_ofRF DEC_grow.st1.fh102 DEC_grow.st1.fb102) (incl_of_footW DEC_grow.st1.fb102 DEC_grow.st1.fc102)

def DEC_grow.st1.fR103 : List (Nat × Nat) := [(4841, 4842), (2672632, 2672633), (3225736, 3225737), (3225755, 3225757), (3225758, 3225759)]
kernel_rfl DEC_grow.st1.fh103 : DEC_grow.st1.s104.heap = setAll DEC_grow.st1.s103.heap (rangesOf DEC_grow.st1.s104.heap DEC_grow.st1.fR103 ++ freshOf DEC_grow.st1.s104.heap DEC_grow.st1.s103.next DEC_grow.st1.s104.next)
kernel_rfl DEC_grow.st1.fb103 : footRB DEC_grow.st1.s103 DEC_grow.st1.s104 DEC_grow.st1.fR103 = true
kernel_rfl DEC_grow.st1.fc103 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s103.next && Nat.ble DEC_grow.st1.s104.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR103 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa104 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s104 :=
  DEC_grow.st1.fa103.step (stageFoot_ofRF DEC_grow.st1.fh103 DEC_grow.st1.fb103) (incl_of_footW DEC_grow.st1.fb103 DEC_grow.st1.fc103)

def DEC_grow.st1.fR104 : List (Nat × Nat) := [(2672632, 2672633), (3076880, 3076881), (3076932, 3076933), (3225737, 3225740), (3225803, 3225810), (3226126, 3226127), (3226536, 3226537), (3226571, 3226572), (3226606, 3226607), (3226631, 3226633), (3226639, 3226646), (3226730, 3226731), (3226760, 3226761), (3226806, 3226807), (3226842, 3226846)]
kernel_rfl DEC_grow.st1.fh104 : DEC_grow.st1.s105.heap = setAll DEC_grow.st1.s104.heap (rangesOf DEC_grow.st1.s105.heap DEC_grow.st1.fR104 ++ freshOf DEC_grow.st1.s105.heap DEC_grow.st1.s104.next DEC_grow.st1.s105.next)
kernel_rfl DEC_grow.st1.fb104 : footRB DEC_grow.st1.s104 DEC_grow.st1.s105 DEC_grow.st1.fR104 = true
kernel_rfl DEC_grow.st1.fc104 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s104.next && Nat.ble DEC_grow.st1.s105.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR104 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa105 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s105 :=
  DEC_grow.st1.fa104.step (stageFoot_ofRF DEC_grow.st1.fh104 DEC_grow.st1.fb104) (incl_of_footW DEC_grow.st1.fb104 DEC_grow.st1.fc104)

def DEC_grow.st1.fR105 : List (Nat × Nat) := [(3123795, 3123796), (3225698, 3225699), (3225765, 3225766), (3227354, 3227355), (3227412, 3227413), (3227418, 3227419), (3227424, 3227425), (3227678, 3227679), (3227699, 3227700), (3227749, 3227750), (3227767, 3227769), (3227801, 3227802), (3227804, 3227814)]
kernel_rfl DEC_grow.st1.fh105 : DEC_grow.st1.s106.heap = setAll DEC_grow.st1.s105.heap (rangesOf DEC_grow.st1.s106.heap DEC_grow.st1.fR105 ++ freshOf DEC_grow.st1.s106.heap DEC_grow.st1.s105.next DEC_grow.st1.s106.next)
kernel_rfl DEC_grow.st1.fb105 : footRB DEC_grow.st1.s105 DEC_grow.st1.s106 DEC_grow.st1.fR105 = true
kernel_rfl DEC_grow.st1.fc105 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s105.next && Nat.ble DEC_grow.st1.s106.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR105 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa106 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s106 :=
  DEC_grow.st1.fa105.step (stageFoot_ofRF DEC_grow.st1.fh105 DEC_grow.st1.fb105) (incl_of_footW DEC_grow.st1.fb105 DEC_grow.st1.fc105)

def DEC_grow.st1.fR106 : List (Nat × Nat) := [(2672641, 2672642), (3078986, 3078987), (3079415, 3079416), (3228178, 3228183), (3228372, 3228373), (3228597, 3228598), (3228683, 3228684), (3228772, 3228773), (3228803, 3228817), (3228820, 3228821)]
kernel_rfl DEC_grow.st1.fh106 : DEC_grow.st1.s107.heap = setAll DEC_grow.st1.s106.heap (rangesOf DEC_grow.st1.s107.heap DEC_grow.st1.fR106 ++ freshOf DEC_grow.st1.s107.heap DEC_grow.st1.s106.next DEC_grow.st1.s107.next)
kernel_rfl DEC_grow.st1.fb106 : footRB DEC_grow.st1.s106 DEC_grow.st1.s107 DEC_grow.st1.fR106 = true
kernel_rfl DEC_grow.st1.fc106 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s106.next && Nat.ble DEC_grow.st1.s107.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR106 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa107 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s107 :=
  DEC_grow.st1.fa106.step (stageFoot_ofRF DEC_grow.st1.fh106 DEC_grow.st1.fb106) (incl_of_footW DEC_grow.st1.fb106 DEC_grow.st1.fc106)

def DEC_grow.st1.fR107 : List (Nat × Nat) := [(3123795, 3123796), (3228070, 3228071), (3228130, 3228133), (3228158, 3228159), (3229772, 3229773)]
kernel_rfl DEC_grow.st1.fh107 : DEC_grow.st1.s108.heap = setAll DEC_grow.st1.s107.heap (rangesOf DEC_grow.st1.s108.heap DEC_grow.st1.fR107 ++ freshOf DEC_grow.st1.s108.heap DEC_grow.st1.s107.next DEC_grow.st1.s108.next)
kernel_rfl DEC_grow.st1.fb107 : footRB DEC_grow.st1.s107 DEC_grow.st1.s108 DEC_grow.st1.fR107 = true
kernel_rfl DEC_grow.st1.fc107 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s107.next && Nat.ble DEC_grow.st1.s108.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR107 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa108 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s108 :=
  DEC_grow.st1.fa107.step (stageFoot_ofRF DEC_grow.st1.fh107 DEC_grow.st1.fb107) (incl_of_footW DEC_grow.st1.fb107 DEC_grow.st1.fc107)

def DEC_grow.st1.fR108 : List (Nat × Nat) := [(2672646, 2672647), (3081378, 3081379), (3230565, 3230570), (3230606, 3230607), (3230686, 3230687), (3230759, 3230761)]
kernel_rfl DEC_grow.st1.fh108 : DEC_grow.st1.s109.heap = setAll DEC_grow.st1.s108.heap (rangesOf DEC_grow.st1.s109.heap DEC_grow.st1.fR108 ++ freshOf DEC_grow.st1.s109.heap DEC_grow.st1.s108.next DEC_grow.st1.s109.next)
kernel_rfl DEC_grow.st1.fb108 : footRB DEC_grow.st1.s108 DEC_grow.st1.s109 DEC_grow.st1.fR108 = true
kernel_rfl DEC_grow.st1.fc108 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s108.next && Nat.ble DEC_grow.st1.s109.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR108 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa109 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s109 :=
  DEC_grow.st1.fa108.step (stageFoot_ofRF DEC_grow.st1.fh108 DEC_grow.st1.fb108) (incl_of_footW DEC_grow.st1.fb108 DEC_grow.st1.fc108)

def DEC_grow.st1.fR109 : List (Nat × Nat) := [(2672646, 2672647), (3081807, 3081808), (3230522, 3230525), (3230570, 3230575), (3230764, 3230765), (3230989, 3230990), (3231075, 3231076), (3231164, 3231165), (3231207, 3231209), (3231530, 3231531), (3231536, 3231537), (3231542, 3231543), (3231571, 3231573), (3231617, 3231618), (3231661, 3231662), (3231683, 3231685), (3231724, 3231725), (3231756, 3231757), (3231759, 3231769), (3231821, 3231822)]
kernel_rfl DEC_grow.st1.fh109 : DEC_grow.st1.s110.heap = setAll DEC_grow.st1.s109.heap (rangesOf DEC_grow.st1.s110.heap DEC_grow.st1.fR109 ++ freshOf DEC_grow.st1.s110.heap DEC_grow.st1.s109.next DEC_grow.st1.s110.next)
kernel_rfl DEC_grow.st1.fb109 : footRB DEC_grow.st1.s109 DEC_grow.st1.s110 DEC_grow.st1.fR109 = true
kernel_rfl DEC_grow.st1.fc109 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s109.next && Nat.ble DEC_grow.st1.s110.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR109 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa110 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s110 :=
  DEC_grow.st1.fa109.step (stageFoot_ofRF DEC_grow.st1.fh109 DEC_grow.st1.fb109) (incl_of_footW DEC_grow.st1.fb109 DEC_grow.st1.fc109)

def DEC_grow.st1.fR110 : List (Nat × Nat) := [(3123795, 3123796), (3230484, 3230485), (3230550, 3230551), (3232164, 3232165), (3232218, 3232219), (3232224, 3232225), (3232230, 3232231), (3232484, 3232485), (3232505, 3232506), (3232555, 3232556), (3232577, 3232579), (3232716, 3232717)]
kernel_rfl DEC_grow.st1.fh110 : DEC_grow.st1.s111.heap = setAll DEC_grow.st1.s110.heap (rangesOf DEC_grow.st1.s111.heap DEC_grow.st1.fR110 ++ freshOf DEC_grow.st1.s111.heap DEC_grow.st1.s110.next DEC_grow.st1.s111.next)
kernel_rfl DEC_grow.st1.fb110 : footRB DEC_grow.st1.s110 DEC_grow.st1.s111 DEC_grow.st1.fR110 = true
kernel_rfl DEC_grow.st1.fc110 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s110.next && Nat.ble DEC_grow.st1.s111.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR110 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa111 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s111 :=
  DEC_grow.st1.fa110.step (stageFoot_ofRF DEC_grow.st1.fh110 DEC_grow.st1.fb110) (incl_of_footW DEC_grow.st1.fb110 DEC_grow.st1.fc110)

def DEC_grow.st1.fR111 : List (Nat × Nat) := [(2672651, 2672652), (3083774, 3083775), (3084203, 3084204), (3232918, 3232921), (3232966, 3232971), (3233160, 3233161), (3233385, 3233386), (3233471, 3233472), (3233560, 3233561), (3233598, 3233605), (3233644, 3233646), (3233698, 3233699), (3233723, 3233724), (3233767, 3233769)]
kernel_rfl DEC_grow.st1.fh111 : DEC_grow.st1.s112.heap = setAll DEC_grow.st1.s111.heap (rangesOf DEC_grow.st1.s112.heap DEC_grow.st1.fR111 ++ freshOf DEC_grow.st1.s112.heap DEC_grow.st1.s111.next DEC_grow.st1.s112.next)
kernel_rfl DEC_grow.st1.fb111 : footRB DEC_grow.st1.s111 DEC_grow.st1.s112 DEC_grow.st1.fR111 = true
kernel_rfl DEC_grow.st1.fc111 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s111.next && Nat.ble DEC_grow.st1.s112.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR111 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa112 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s112 :=
  DEC_grow.st1.fa111.step (stageFoot_ofRF DEC_grow.st1.fh111 DEC_grow.st1.fb111) (incl_of_footW DEC_grow.st1.fb111 DEC_grow.st1.fc111)

def DEC_grow.st1.fR112 : List (Nat × Nat) := [(3123795, 3123796), (3232880, 3232881), (3232946, 3232947), (3234560, 3234561), (3234614, 3234615), (3234620, 3234621), (3234626, 3234627), (3234634, 3234635), (3234646, 3234649), (3234703, 3234704)]
kernel_rfl DEC_grow.st1.fh112 : DEC_grow.st1.s113.heap = setAll DEC_grow.st1.s112.heap (rangesOf DEC_grow.st1.s113.heap DEC_grow.st1.fR112 ++ freshOf DEC_grow.st1.s113.heap DEC_grow.st1.s112.next DEC_grow.st1.s113.next)
kernel_rfl DEC_grow.st1.fb112 : footRB DEC_grow.st1.s112 DEC_grow.st1.s113 DEC_grow.st1.fR112 = true
kernel_rfl DEC_grow.st1.fc112 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s112.next && Nat.ble DEC_grow.st1.s113.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR112 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa113 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s113 :=
  DEC_grow.st1.fa112.step (stageFoot_ofRF DEC_grow.st1.fh112 DEC_grow.st1.fb112) (incl_of_footW DEC_grow.st1.fb112 DEC_grow.st1.fc112)

def DEC_grow.st1.fR113 : List (Nat × Nat) := [(4841, 4842), (2672663, 2672664), (3086262, 3086263), (3086314, 3086315), (3235377, 3235383), (3235609, 3235610), (3235673, 3235674)]
kernel_rfl DEC_grow.st1.fh113 : DEC_grow.st1.s114.heap = setAll DEC_grow.st1.s113.heap (rangesOf DEC_grow.st1.s114.heap DEC_grow.st1.fR113 ++ freshOf DEC_grow.st1.s114.heap DEC_grow.st1.s113.next DEC_grow.st1.s114.next)
kernel_rfl DEC_grow.st1.fb113 : footRB DEC_grow.st1.s113 DEC_grow.st1.s114 DEC_grow.st1.fR113 = true
kernel_rfl DEC_grow.st1.fc113 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s113.next && Nat.ble DEC_grow.st1.s114.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR113 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa114 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s114 :=
  DEC_grow.st1.fa113.step (stageFoot_ofRF DEC_grow.st1.fh113 DEC_grow.st1.fb113) (incl_of_footW DEC_grow.st1.fb113 DEC_grow.st1.fc113)

def DEC_grow.st1.fR114 : List (Nat × Nat) := [(3123795, 3123796), (3235276, 3235277), (3235315, 3235318), (3235343, 3235344), (3235383, 3235388), (3235704, 3235705), (3236149, 3236150), (3236673, 3236674), (3236722, 3236723)]
kernel_rfl DEC_grow.st1.fh114 : DEC_grow.st1.s115.heap = setAll DEC_grow.st1.s114.heap (rangesOf DEC_grow.st1.s115.heap DEC_grow.st1.fR114 ++ freshOf DEC_grow.st1.s115.heap DEC_grow.st1.s114.next DEC_grow.st1.s115.next)
kernel_rfl DEC_grow.st1.fb114 : footRB DEC_grow.st1.s114 DEC_grow.st1.s115 DEC_grow.st1.fR114 = true
kernel_rfl DEC_grow.st1.fc114 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s114.next && Nat.ble DEC_grow.st1.s115.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR114 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa115 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s115 :=
  DEC_grow.st1.fa114.step (stageFoot_ofRF DEC_grow.st1.fh114 DEC_grow.st1.fb114) (incl_of_footW DEC_grow.st1.fb114 DEC_grow.st1.fc114)

def DEC_grow.st1.fR115 : List (Nat × Nat) := [(2672672, 2672673), (3088372, 3088373)]
kernel_rfl DEC_grow.st1.fh115 : DEC_grow.st1.s116.heap = setAll DEC_grow.st1.s115.heap (rangesOf DEC_grow.st1.s116.heap DEC_grow.st1.fR115 ++ freshOf DEC_grow.st1.s116.heap DEC_grow.st1.s115.next DEC_grow.st1.s116.next)
kernel_rfl DEC_grow.st1.fb115 : footRB DEC_grow.st1.s115 DEC_grow.st1.s116 DEC_grow.st1.fR115 = true
kernel_rfl DEC_grow.st1.fc115 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s115.next && Nat.ble DEC_grow.st1.s116.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR115 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa116 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s116 :=
  DEC_grow.st1.fa115.step (stageFoot_ofRF DEC_grow.st1.fh115 DEC_grow.st1.fb115) (incl_of_footW DEC_grow.st1.fb115 DEC_grow.st1.fc115)

def DEC_grow.st1.fR116 : List (Nat × Nat) := [(2672672, 2672673), (3088801, 3088802), (3237712, 3237715), (3237760, 3237765), (3237954, 3237955), (3238179, 3238180), (3238265, 3238266), (3238354, 3238355), (3238397, 3238399), (3238720, 3238721), (3238726, 3238727), (3238732, 3238733)]
kernel_rfl DEC_grow.st1.fh116 : DEC_grow.st1.s117.heap = setAll DEC_grow.st1.s116.heap (rangesOf DEC_grow.st1.s117.heap DEC_grow.st1.fR116 ++ freshOf DEC_grow.st1.s117.heap DEC_grow.st1.s116.next DEC_grow.st1.s117.next)
kernel_rfl DEC_grow.st1.fb116 : footRB DEC_grow.st1.s116 DEC_grow.st1.s117 DEC_grow.st1.fR116 = true
kernel_rfl DEC_grow.st1.fc116 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s116.next && Nat.ble DEC_grow.st1.s117.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR116 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa117 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s117 :=
  DEC_grow.st1.fa116.step (stageFoot_ofRF DEC_grow.st1.fh116 DEC_grow.st1.fb116) (incl_of_footW DEC_grow.st1.fb116 DEC_grow.st1.fc116)

def DEC_grow.st1.fR117 : List (Nat × Nat) := [(3123795, 3123796), (3237652, 3237653), (3237740, 3237741), (3239354, 3239355), (3239408, 3239409), (3239414, 3239415), (3239420, 3239421), (3239428, 3239429), (3239442, 3239443), (3239643, 3239644), (3239667, 3239668)]
kernel_rfl DEC_grow.st1.fh117 : DEC_grow.st1.s118.heap = setAll DEC_grow.st1.s117.heap (rangesOf DEC_grow.st1.s118.heap DEC_grow.st1.fR117 ++ freshOf DEC_grow.st1.s118.heap DEC_grow.st1.s117.next DEC_grow.st1.s118.next)
kernel_rfl DEC_grow.st1.fb117 : footRB DEC_grow.st1.s117 DEC_grow.st1.s118 DEC_grow.st1.fR117 = true
kernel_rfl DEC_grow.st1.fc117 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s117.next && Nat.ble DEC_grow.st1.s118.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR117 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa118 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s118 :=
  DEC_grow.st1.fa117.step (stageFoot_ofRF DEC_grow.st1.fh117 DEC_grow.st1.fb117) (incl_of_footW DEC_grow.st1.fb117 DEC_grow.st1.fc117)

def DEC_grow.st1.fR118 : List (Nat × Nat) := [(2672677, 2672678), (3090768, 3090769), (3091197, 3091198), (3240153, 3240160), (3240350, 3240351), (3240575, 3240576), (3240588, 3240589), (3240661, 3240662)]
kernel_rfl DEC_grow.st1.fh118 : DEC_grow.st1.s119.heap = setAll DEC_grow.st1.s118.heap (rangesOf DEC_grow.st1.s119.heap DEC_grow.st1.fR118 ++ freshOf DEC_grow.st1.s119.heap DEC_grow.st1.s118.next DEC_grow.st1.s119.next)
kernel_rfl DEC_grow.st1.fb118 : footRB DEC_grow.st1.s118 DEC_grow.st1.s119 DEC_grow.st1.fR118 = true
kernel_rfl DEC_grow.st1.fc118 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s118.next && Nat.ble DEC_grow.st1.s119.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR118 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa119 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s119 :=
  DEC_grow.st1.fa118.step (stageFoot_ofRF DEC_grow.st1.fh118 DEC_grow.st1.fb118) (incl_of_footW DEC_grow.st1.fb118 DEC_grow.st1.fc118)

def DEC_grow.st1.fR119 : List (Nat × Nat) := [(3123795, 3123796), (3240070, 3240071), (3240108, 3240111), (3240136, 3240137), (3240160, 3240161), (3241567, 3241568), (3241592, 3241593), (3241660, 3241661), (3241663, 3241673)]
kernel_rfl DEC_grow.st1.fh119 : DEC_grow.st1.s120.heap = setAll DEC_grow.st1.s119.heap (rangesOf DEC_grow.st1.s120.heap DEC_grow.st1.fR119 ++ freshOf DEC_grow.st1.s120.heap DEC_grow.st1.s119.next DEC_grow.st1.s120.next)
kernel_rfl DEC_grow.st1.fb119 : footRB DEC_grow.st1.s119 DEC_grow.st1.s120 DEC_grow.st1.fR119 = true
kernel_rfl DEC_grow.st1.fc119 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s119.next && Nat.ble DEC_grow.st1.s120.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR119 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa120 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s120 :=
  DEC_grow.st1.fa119.step (stageFoot_ofRF DEC_grow.st1.fh119 DEC_grow.st1.fb119) (incl_of_footW DEC_grow.st1.fb119 DEC_grow.st1.fc119)

def DEC_grow.st1.fR120 : List (Nat × Nat) := [(2672682, 2672683), (3093164, 3093165), (3242547, 3242552), (3242588, 3242589), (3242620, 3242622)]
kernel_rfl DEC_grow.st1.fh120 : DEC_grow.st1.s121.heap = setAll DEC_grow.st1.s120.heap (rangesOf DEC_grow.st1.s121.heap DEC_grow.st1.fR120 ++ freshOf DEC_grow.st1.s121.heap DEC_grow.st1.s120.next DEC_grow.st1.s121.next)
kernel_rfl DEC_grow.st1.fb120 : footRB DEC_grow.st1.s120 DEC_grow.st1.s121 DEC_grow.st1.fR120 = true
kernel_rfl DEC_grow.st1.fc120 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s120.next && Nat.ble DEC_grow.st1.s121.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR120 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa121 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s121 :=
  DEC_grow.st1.fa120.step (stageFoot_ofRF DEC_grow.st1.fh120 DEC_grow.st1.fb120) (incl_of_footW DEC_grow.st1.fb120 DEC_grow.st1.fc120)

def DEC_grow.st1.fR121 : List (Nat × Nat) := [(2672682, 2672683), (3093593, 3093594), (3242504, 3242507), (3242552, 3242557), (3242746, 3242747), (3242971, 3242972), (3243057, 3243058), (3243146, 3243147), (3243189, 3243191), (3243512, 3243513), (3243518, 3243519), (3243524, 3243525), (3243553, 3243555), (3243599, 3243600), (3243643, 3243644), (3243661, 3243667), (3243683, 3243684)]
kernel_rfl DEC_grow.st1.fh121 : DEC_grow.st1.s122.heap = setAll DEC_grow.st1.s121.heap (rangesOf DEC_grow.st1.s122.heap DEC_grow.st1.fR121 ++ freshOf DEC_grow.st1.s122.heap DEC_grow.st1.s121.next DEC_grow.st1.s122.next)
kernel_rfl DEC_grow.st1.fb121 : footRB DEC_grow.st1.s121 DEC_grow.st1.s122 DEC_grow.st1.fR121 = true
kernel_rfl DEC_grow.st1.fc121 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s121.next && Nat.ble DEC_grow.st1.s122.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR121 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa122 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s122 :=
  DEC_grow.st1.fa121.step (stageFoot_ofRF DEC_grow.st1.fh121 DEC_grow.st1.fb121) (incl_of_footW DEC_grow.st1.fb121 DEC_grow.st1.fc121)

def DEC_grow.st1.fR122 : List (Nat × Nat) := [(3123795, 3123796), (3242466, 3242467), (3242532, 3242533), (3244146, 3244147), (3244200, 3244201), (3244206, 3244207), (3244212, 3244213), (3244466, 3244467), (3244487, 3244488), (3244537, 3244538), (3244555, 3244557), (3244589, 3244590), (3244592, 3244602)]
kernel_rfl DEC_grow.st1.fh122 : DEC_grow.st1.s123.heap = setAll DEC_grow.st1.s122.heap (rangesOf DEC_grow.st1.s123.heap DEC_grow.st1.fR122 ++ freshOf DEC_grow.st1.s123.heap DEC_grow.st1.s122.next DEC_grow.st1.s123.next)
kernel_rfl DEC_grow.st1.fb122 : footRB DEC_grow.st1.s122 DEC_grow.st1.s123 DEC_grow.st1.fR122 = true
kernel_rfl DEC_grow.st1.fc122 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s122.next && Nat.ble DEC_grow.st1.s123.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR122 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa123 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s123 :=
  DEC_grow.st1.fa122.step (stageFoot_ofRF DEC_grow.st1.fh122 DEC_grow.st1.fb122) (incl_of_footW DEC_grow.st1.fb122 DEC_grow.st1.fc122)

def DEC_grow.st1.fR123 : List (Nat × Nat) := [(4841, 4842), (2672694, 2672695), (3095648, 3095649), (3095700, 3095701), (3244897, 3244900), (3244960, 3244970), (3245286, 3245287), (3245461, 3245462), (3245529, 3245530), (3245597, 3245598), (3245621, 3245624), (3245625, 3245626)]
kernel_rfl DEC_grow.st1.fh123 : DEC_grow.st1.s124.heap = setAll DEC_grow.st1.s123.heap (rangesOf DEC_grow.st1.s124.heap DEC_grow.st1.fR123 ++ freshOf DEC_grow.st1.s124.heap DEC_grow.st1.s123.next DEC_grow.st1.s124.next)
kernel_rfl DEC_grow.st1.fb123 : footRB DEC_grow.st1.s123 DEC_grow.st1.s124 DEC_grow.st1.fR123 = true
kernel_rfl DEC_grow.st1.fc123 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s123.next && Nat.ble DEC_grow.st1.s124.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR123 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa124 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s124 :=
  DEC_grow.st1.fa123.step (stageFoot_ofRF DEC_grow.st1.fh123 DEC_grow.st1.fb123) (incl_of_footW DEC_grow.st1.fb123 DEC_grow.st1.fc123)

def DEC_grow.st1.fR124 : List (Nat × Nat) := [(3123795, 3123796), (3244858, 3244859), (3244925, 3244926), (3246514, 3246515), (3246572, 3246573), (3246578, 3246579), (3246584, 3246585), (3246592, 3246593), (3246603, 3246607)]
kernel_rfl DEC_grow.st1.fh124 : DEC_grow.st1.s125.heap = setAll DEC_grow.st1.s124.heap (rangesOf DEC_grow.st1.s125.heap DEC_grow.st1.fR124 ++ freshOf DEC_grow.st1.s125.heap DEC_grow.st1.s124.next DEC_grow.st1.s125.next)
kernel_rfl DEC_grow.st1.fb124 : footRB DEC_grow.st1.s124 DEC_grow.st1.s125 DEC_grow.st1.fR124 = true
kernel_rfl DEC_grow.st1.fc124 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s124.next && Nat.ble DEC_grow.st1.s125.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR124 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa125 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s125 :=
  DEC_grow.st1.fa124.step (stageFoot_ofRF DEC_grow.st1.fh124 DEC_grow.st1.fb124) (incl_of_footW DEC_grow.st1.fb124 DEC_grow.st1.fc124)

def DEC_grow.st1.fR125 : List (Nat × Nat) := [(2672703, 2672704), (3097754, 3097755), (3247334, 3247338), (3247563, 3247564), (3247595, 3247596), (3247619, 3247620)]
kernel_rfl DEC_grow.st1.fh125 : DEC_grow.st1.s126.heap = setAll DEC_grow.st1.s125.heap (rangesOf DEC_grow.st1.s126.heap DEC_grow.st1.fR125 ++ freshOf DEC_grow.st1.s126.heap DEC_grow.st1.s125.next DEC_grow.st1.s126.next)
kernel_rfl DEC_grow.st1.fb125 : footRB DEC_grow.st1.s125 DEC_grow.st1.s126 DEC_grow.st1.fR125 = true
kernel_rfl DEC_grow.st1.fc125 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s125.next && Nat.ble DEC_grow.st1.s126.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR125 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa126 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s126 :=
  DEC_grow.st1.fa125.step (stageFoot_ofRF DEC_grow.st1.fh125 DEC_grow.st1.fb125) (incl_of_footW DEC_grow.st1.fb125 DEC_grow.st1.fc125)

def DEC_grow.st1.fR126 : List (Nat × Nat) := [(2672703, 2672704), (3098183, 3098184), (3247290, 3247293), (3247338, 3247343), (3247532, 3247533), (3247757, 3247758), (3247843, 3247844), (3247932, 3247933), (3247975, 3247977), (3248298, 3248299), (3248304, 3248305), (3248310, 3248311), (3248339, 3248341), (3248385, 3248386), (3248429, 3248430), (3248630, 3248631)]
kernel_rfl DEC_grow.st1.fh126 : DEC_grow.st1.s127.heap = setAll DEC_grow.st1.s126.heap (rangesOf DEC_grow.st1.s127.heap DEC_grow.st1.fR126 ++ freshOf DEC_grow.st1.s127.heap DEC_grow.st1.s126.next DEC_grow.st1.s127.next)
kernel_rfl DEC_grow.st1.fb126 : footRB DEC_grow.st1.s126 DEC_grow.st1.s127 DEC_grow.st1.fR126 = true
kernel_rfl DEC_grow.st1.fc126 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s126.next && Nat.ble DEC_grow.st1.s127.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR126 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa127 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s127 :=
  DEC_grow.st1.fa126.step (stageFoot_ofRF DEC_grow.st1.fh126 DEC_grow.st1.fb126) (incl_of_footW DEC_grow.st1.fb126 DEC_grow.st1.fc126)

def DEC_grow.st1.fR127 : List (Nat × Nat) := [(2672708, 2672709), (3100046, 3100047), (3123795, 3123796), (3247230, 3247231), (3247318, 3247319), (3248932, 3248933), (3248986, 3248987), (3248992, 3248993), (3248998, 3248999), (3249252, 3249253), (3249273, 3249274), (3249323, 3249324), (3249342, 3249343), (3249485, 3249486), (3249563, 3249565)]
kernel_rfl DEC_grow.st1.fh127 : DEC_grow.st1.s128.heap = setAll DEC_grow.st1.s127.heap (rangesOf DEC_grow.st1.s128.heap DEC_grow.st1.fR127 ++ freshOf DEC_grow.st1.s128.heap DEC_grow.st1.s127.next DEC_grow.st1.s128.next)
kernel_rfl DEC_grow.st1.fb127 : footRB DEC_grow.st1.s127 DEC_grow.st1.s128 DEC_grow.st1.fR127 = true
kernel_rfl DEC_grow.st1.fc127 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s127.next && Nat.ble DEC_grow.st1.s128.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR127 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa128 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s128 :=
  DEC_grow.st1.fa127.step (stageFoot_ofRF DEC_grow.st1.fh127 DEC_grow.st1.fb127) (incl_of_footW DEC_grow.st1.fb127 DEC_grow.st1.fc127)

end Host.Load.Run.Tpl

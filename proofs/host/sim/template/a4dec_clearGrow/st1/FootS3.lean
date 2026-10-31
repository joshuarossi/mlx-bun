import host.sim.template.a4dec_clearGrow.st1.FootS2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearGrow.st1.fR96 : List (Nat × Nat) := [(2672610, 2672611), (3069612, 3069613), (3218605, 3218609), (3218834, 3218835), (3218900, 3218902)]
kernel_rfl DEC_clearGrow.st1.fh96 : DEC_clearGrow.st1.s97.heap = setAll DEC_clearGrow.st1.s96.heap (rangesOf DEC_clearGrow.st1.s97.heap DEC_clearGrow.st1.fR96 ++ freshOf DEC_clearGrow.st1.s97.heap DEC_clearGrow.st1.s96.next DEC_clearGrow.st1.s97.next)
kernel_rfl DEC_clearGrow.st1.fb96 : footRB DEC_clearGrow.st1.s96 DEC_clearGrow.st1.s97 DEC_clearGrow.st1.fR96 = true
kernel_rfl DEC_clearGrow.st1.fc96 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s96.next && Nat.ble DEC_clearGrow.st1.s97.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR96 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa97 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s97 :=
  DEC_clearGrow.st1.fa96.step (stageFoot_ofRF DEC_clearGrow.st1.fh96 DEC_clearGrow.st1.fb96) (incl_of_footW DEC_clearGrow.st1.fb96 DEC_clearGrow.st1.fc96)

def DEC_clearGrow.st1.fR97 : List (Nat × Nat) := [(2672610, 2672611), (3070041, 3070042), (3218561, 3218564), (3218609, 3218614), (3218803, 3218804), (3219028, 3219029), (3219114, 3219115), (3219203, 3219204), (3219246, 3219248), (3219569, 3219570), (3219575, 3219576), (3219581, 3219582), (3219700, 3219701), (3219901, 3219902)]
kernel_rfl DEC_clearGrow.st1.fh97 : DEC_clearGrow.st1.s98.heap = setAll DEC_clearGrow.st1.s97.heap (rangesOf DEC_clearGrow.st1.s98.heap DEC_clearGrow.st1.fR97 ++ freshOf DEC_clearGrow.st1.s98.heap DEC_clearGrow.st1.s97.next DEC_clearGrow.st1.s98.next)
kernel_rfl DEC_clearGrow.st1.fb97 : footRB DEC_clearGrow.st1.s97 DEC_clearGrow.st1.s98 DEC_clearGrow.st1.fR97 = true
kernel_rfl DEC_clearGrow.st1.fc97 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s97.next && Nat.ble DEC_clearGrow.st1.s98.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR97 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa98 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s98 :=
  DEC_clearGrow.st1.fa97.step (stageFoot_ofRF DEC_clearGrow.st1.fh97 DEC_clearGrow.st1.fb97) (incl_of_footW DEC_clearGrow.st1.fb97 DEC_clearGrow.st1.fc97)

def DEC_clearGrow.st1.fR98 : List (Nat × Nat) := [(3123796, 3123797), (3218501, 3218502), (3218589, 3218590), (3220203, 3220204), (3220257, 3220258), (3220263, 3220264), (3220269, 3220270), (3220523, 3220524), (3220544, 3220545), (3220594, 3220595), (3220613, 3220614), (3220756, 3220757), (3220834, 3220835)]
kernel_rfl DEC_clearGrow.st1.fh98 : DEC_clearGrow.st1.s99.heap = setAll DEC_clearGrow.st1.s98.heap (rangesOf DEC_clearGrow.st1.s99.heap DEC_clearGrow.st1.fR98 ++ freshOf DEC_clearGrow.st1.s99.heap DEC_clearGrow.st1.s98.next DEC_clearGrow.st1.s99.next)
kernel_rfl DEC_clearGrow.st1.fb98 : footRB DEC_clearGrow.st1.s98 DEC_clearGrow.st1.s99 DEC_clearGrow.st1.fR98 = true
kernel_rfl DEC_clearGrow.st1.fc98 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s98.next && Nat.ble DEC_clearGrow.st1.s99.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR98 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa99 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s99 :=
  DEC_clearGrow.st1.fa98.step (stageFoot_ofRF DEC_clearGrow.st1.fh98 DEC_clearGrow.st1.fb98) (incl_of_footW DEC_clearGrow.st1.fb98 DEC_clearGrow.st1.fc98)

def DEC_clearGrow.st1.fR99 : List (Nat × Nat) := [(2672615, 2672616), (3072004, 3072005), (3072433, 3072434), (3220953, 3220956), (3221001, 3221006), (3221195, 3221196), (3221420, 3221421), (3221506, 3221507), (3221595, 3221596), (3221633, 3221640), (3221680, 3221681), (3221733, 3221734), (3221904, 3221905)]
kernel_rfl DEC_clearGrow.st1.fh99 : DEC_clearGrow.st1.s100.heap = setAll DEC_clearGrow.st1.s99.heap (rangesOf DEC_clearGrow.st1.s100.heap DEC_clearGrow.st1.fR99 ++ freshOf DEC_clearGrow.st1.s100.heap DEC_clearGrow.st1.s99.next DEC_clearGrow.st1.s100.next)
kernel_rfl DEC_clearGrow.st1.fb99 : footRB DEC_clearGrow.st1.s99 DEC_clearGrow.st1.s100 DEC_clearGrow.st1.fR99 = true
kernel_rfl DEC_clearGrow.st1.fc99 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s99.next && Nat.ble DEC_clearGrow.st1.s100.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR99 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa100 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s100 :=
  DEC_clearGrow.st1.fa99.step (stageFoot_ofRF DEC_clearGrow.st1.fh99 DEC_clearGrow.st1.fb99) (incl_of_footW DEC_clearGrow.st1.fb99 DEC_clearGrow.st1.fc99)

def DEC_clearGrow.st1.fR100 : List (Nat × Nat) := [(3123796, 3123797), (3220915, 3220916), (3220981, 3220982), (3222595, 3222596), (3222649, 3222650), (3222655, 3222656), (3222661, 3222662), (3222669, 3222670), (3222682, 3222684), (3222738, 3222739), (3222766, 3222767), (3222769, 3222779), (3222840, 3222842)]
kernel_rfl DEC_clearGrow.st1.fh100 : DEC_clearGrow.st1.s101.heap = setAll DEC_clearGrow.st1.s100.heap (rangesOf DEC_clearGrow.st1.s101.heap DEC_clearGrow.st1.fR100 ++ freshOf DEC_clearGrow.st1.s101.heap DEC_clearGrow.st1.s100.next DEC_clearGrow.st1.s101.next)
kernel_rfl DEC_clearGrow.st1.fb100 : footRB DEC_clearGrow.st1.s100 DEC_clearGrow.st1.s101 DEC_clearGrow.st1.fR100 = true
kernel_rfl DEC_clearGrow.st1.fc100 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s100.next && Nat.ble DEC_clearGrow.st1.s101.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR100 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa101 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s101 :=
  DEC_clearGrow.st1.fa100.step (stageFoot_ofRF DEC_clearGrow.st1.fh100 DEC_clearGrow.st1.fb100) (incl_of_footW DEC_clearGrow.st1.fb100 DEC_clearGrow.st1.fc100)

def DEC_clearGrow.st1.fR101 : List (Nat × Nat) := [(2672620, 2672621), (3074396, 3074397), (3074825, 3074826), (3223389, 3223397), (3223587, 3223588), (3223776, 3223777), (3223804, 3223806), (3223807, 3223808)]
kernel_rfl DEC_clearGrow.st1.fh101 : DEC_clearGrow.st1.s102.heap = setAll DEC_clearGrow.st1.s101.heap (rangesOf DEC_clearGrow.st1.s102.heap DEC_clearGrow.st1.fR101 ++ freshOf DEC_clearGrow.st1.s102.heap DEC_clearGrow.st1.s101.next DEC_clearGrow.st1.s102.next)
kernel_rfl DEC_clearGrow.st1.fb101 : footRB DEC_clearGrow.st1.s101 DEC_clearGrow.st1.s102 DEC_clearGrow.st1.fR101 = true
kernel_rfl DEC_clearGrow.st1.fc101 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s101.next && Nat.ble DEC_clearGrow.st1.s102.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR101 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa102 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s102 :=
  DEC_clearGrow.st1.fa101.step (stageFoot_ofRF DEC_clearGrow.st1.fh101 DEC_clearGrow.st1.fb101) (incl_of_footW DEC_clearGrow.st1.fb101 DEC_clearGrow.st1.fc101)

def DEC_clearGrow.st1.fR102 : List (Nat × Nat) := [(3123796, 3123797), (3223307, 3223308), (3223345, 3223348), (3223373, 3223374), (3223397, 3223398), (3224804, 3224805)]
kernel_rfl DEC_clearGrow.st1.fh102 : DEC_clearGrow.st1.s103.heap = setAll DEC_clearGrow.st1.s102.heap (rangesOf DEC_clearGrow.st1.s103.heap DEC_clearGrow.st1.fR102 ++ freshOf DEC_clearGrow.st1.s103.heap DEC_clearGrow.st1.s102.next DEC_clearGrow.st1.s103.next)
kernel_rfl DEC_clearGrow.st1.fb102 : footRB DEC_clearGrow.st1.s102 DEC_clearGrow.st1.s103 DEC_clearGrow.st1.fR102 = true
kernel_rfl DEC_clearGrow.st1.fc102 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s102.next && Nat.ble DEC_clearGrow.st1.s103.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR102 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa103 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s103 :=
  DEC_clearGrow.st1.fa102.step (stageFoot_ofRF DEC_clearGrow.st1.fh102 DEC_clearGrow.st1.fb102) (incl_of_footW DEC_clearGrow.st1.fb102 DEC_clearGrow.st1.fc102)

def DEC_clearGrow.st1.fR103 : List (Nat × Nat) := [(4841, 4842), (2672632, 2672633), (3225737, 3225738), (3225756, 3225758), (3225759, 3225760)]
kernel_rfl DEC_clearGrow.st1.fh103 : DEC_clearGrow.st1.s104.heap = setAll DEC_clearGrow.st1.s103.heap (rangesOf DEC_clearGrow.st1.s104.heap DEC_clearGrow.st1.fR103 ++ freshOf DEC_clearGrow.st1.s104.heap DEC_clearGrow.st1.s103.next DEC_clearGrow.st1.s104.next)
kernel_rfl DEC_clearGrow.st1.fb103 : footRB DEC_clearGrow.st1.s103 DEC_clearGrow.st1.s104 DEC_clearGrow.st1.fR103 = true
kernel_rfl DEC_clearGrow.st1.fc103 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s103.next && Nat.ble DEC_clearGrow.st1.s104.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR103 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa104 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s104 :=
  DEC_clearGrow.st1.fa103.step (stageFoot_ofRF DEC_clearGrow.st1.fh103 DEC_clearGrow.st1.fb103) (incl_of_footW DEC_clearGrow.st1.fb103 DEC_clearGrow.st1.fc103)

def DEC_clearGrow.st1.fR104 : List (Nat × Nat) := [(2672632, 2672633), (3076880, 3076881), (3076932, 3076933), (3225738, 3225741), (3225804, 3225811), (3226127, 3226128), (3226537, 3226538), (3226572, 3226573), (3226607, 3226608), (3226632, 3226634), (3226640, 3226647), (3226731, 3226732), (3226761, 3226762), (3226807, 3226808), (3226843, 3226847)]
kernel_rfl DEC_clearGrow.st1.fh104 : DEC_clearGrow.st1.s105.heap = setAll DEC_clearGrow.st1.s104.heap (rangesOf DEC_clearGrow.st1.s105.heap DEC_clearGrow.st1.fR104 ++ freshOf DEC_clearGrow.st1.s105.heap DEC_clearGrow.st1.s104.next DEC_clearGrow.st1.s105.next)
kernel_rfl DEC_clearGrow.st1.fb104 : footRB DEC_clearGrow.st1.s104 DEC_clearGrow.st1.s105 DEC_clearGrow.st1.fR104 = true
kernel_rfl DEC_clearGrow.st1.fc104 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s104.next && Nat.ble DEC_clearGrow.st1.s105.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR104 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa105 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s105 :=
  DEC_clearGrow.st1.fa104.step (stageFoot_ofRF DEC_clearGrow.st1.fh104 DEC_clearGrow.st1.fb104) (incl_of_footW DEC_clearGrow.st1.fb104 DEC_clearGrow.st1.fc104)

def DEC_clearGrow.st1.fR105 : List (Nat × Nat) := [(3123796, 3123797), (3225699, 3225700), (3225766, 3225767), (3227355, 3227356), (3227413, 3227414), (3227419, 3227420), (3227425, 3227426), (3227679, 3227680), (3227700, 3227701), (3227750, 3227751), (3227768, 3227770), (3227802, 3227803), (3227805, 3227815)]
kernel_rfl DEC_clearGrow.st1.fh105 : DEC_clearGrow.st1.s106.heap = setAll DEC_clearGrow.st1.s105.heap (rangesOf DEC_clearGrow.st1.s106.heap DEC_clearGrow.st1.fR105 ++ freshOf DEC_clearGrow.st1.s106.heap DEC_clearGrow.st1.s105.next DEC_clearGrow.st1.s106.next)
kernel_rfl DEC_clearGrow.st1.fb105 : footRB DEC_clearGrow.st1.s105 DEC_clearGrow.st1.s106 DEC_clearGrow.st1.fR105 = true
kernel_rfl DEC_clearGrow.st1.fc105 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s105.next && Nat.ble DEC_clearGrow.st1.s106.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR105 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa106 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s106 :=
  DEC_clearGrow.st1.fa105.step (stageFoot_ofRF DEC_clearGrow.st1.fh105 DEC_clearGrow.st1.fb105) (incl_of_footW DEC_clearGrow.st1.fb105 DEC_clearGrow.st1.fc105)

def DEC_clearGrow.st1.fR106 : List (Nat × Nat) := [(2672641, 2672642), (3078986, 3078987), (3079415, 3079416), (3228179, 3228184), (3228373, 3228374), (3228598, 3228599), (3228684, 3228685), (3228773, 3228774), (3228804, 3228818), (3228821, 3228822)]
kernel_rfl DEC_clearGrow.st1.fh106 : DEC_clearGrow.st1.s107.heap = setAll DEC_clearGrow.st1.s106.heap (rangesOf DEC_clearGrow.st1.s107.heap DEC_clearGrow.st1.fR106 ++ freshOf DEC_clearGrow.st1.s107.heap DEC_clearGrow.st1.s106.next DEC_clearGrow.st1.s107.next)
kernel_rfl DEC_clearGrow.st1.fb106 : footRB DEC_clearGrow.st1.s106 DEC_clearGrow.st1.s107 DEC_clearGrow.st1.fR106 = true
kernel_rfl DEC_clearGrow.st1.fc106 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s106.next && Nat.ble DEC_clearGrow.st1.s107.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR106 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa107 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s107 :=
  DEC_clearGrow.st1.fa106.step (stageFoot_ofRF DEC_clearGrow.st1.fh106 DEC_clearGrow.st1.fb106) (incl_of_footW DEC_clearGrow.st1.fb106 DEC_clearGrow.st1.fc106)

def DEC_clearGrow.st1.fR107 : List (Nat × Nat) := [(3123796, 3123797), (3228071, 3228072), (3228131, 3228134), (3228159, 3228160), (3229773, 3229774)]
kernel_rfl DEC_clearGrow.st1.fh107 : DEC_clearGrow.st1.s108.heap = setAll DEC_clearGrow.st1.s107.heap (rangesOf DEC_clearGrow.st1.s108.heap DEC_clearGrow.st1.fR107 ++ freshOf DEC_clearGrow.st1.s108.heap DEC_clearGrow.st1.s107.next DEC_clearGrow.st1.s108.next)
kernel_rfl DEC_clearGrow.st1.fb107 : footRB DEC_clearGrow.st1.s107 DEC_clearGrow.st1.s108 DEC_clearGrow.st1.fR107 = true
kernel_rfl DEC_clearGrow.st1.fc107 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s107.next && Nat.ble DEC_clearGrow.st1.s108.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR107 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa108 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s108 :=
  DEC_clearGrow.st1.fa107.step (stageFoot_ofRF DEC_clearGrow.st1.fh107 DEC_clearGrow.st1.fb107) (incl_of_footW DEC_clearGrow.st1.fb107 DEC_clearGrow.st1.fc107)

def DEC_clearGrow.st1.fR108 : List (Nat × Nat) := [(2672646, 2672647), (3081378, 3081379), (3230566, 3230571), (3230607, 3230608), (3230687, 3230688), (3230760, 3230762)]
kernel_rfl DEC_clearGrow.st1.fh108 : DEC_clearGrow.st1.s109.heap = setAll DEC_clearGrow.st1.s108.heap (rangesOf DEC_clearGrow.st1.s109.heap DEC_clearGrow.st1.fR108 ++ freshOf DEC_clearGrow.st1.s109.heap DEC_clearGrow.st1.s108.next DEC_clearGrow.st1.s109.next)
kernel_rfl DEC_clearGrow.st1.fb108 : footRB DEC_clearGrow.st1.s108 DEC_clearGrow.st1.s109 DEC_clearGrow.st1.fR108 = true
kernel_rfl DEC_clearGrow.st1.fc108 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s108.next && Nat.ble DEC_clearGrow.st1.s109.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR108 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa109 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s109 :=
  DEC_clearGrow.st1.fa108.step (stageFoot_ofRF DEC_clearGrow.st1.fh108 DEC_clearGrow.st1.fb108) (incl_of_footW DEC_clearGrow.st1.fb108 DEC_clearGrow.st1.fc108)

def DEC_clearGrow.st1.fR109 : List (Nat × Nat) := [(2672646, 2672647), (3081807, 3081808), (3230523, 3230526), (3230571, 3230576), (3230765, 3230766), (3230990, 3230991), (3231076, 3231077), (3231165, 3231166), (3231208, 3231210), (3231531, 3231532), (3231537, 3231538), (3231543, 3231544), (3231572, 3231574), (3231618, 3231619), (3231662, 3231663), (3231684, 3231686), (3231725, 3231726), (3231757, 3231758), (3231760, 3231770), (3231822, 3231823)]
kernel_rfl DEC_clearGrow.st1.fh109 : DEC_clearGrow.st1.s110.heap = setAll DEC_clearGrow.st1.s109.heap (rangesOf DEC_clearGrow.st1.s110.heap DEC_clearGrow.st1.fR109 ++ freshOf DEC_clearGrow.st1.s110.heap DEC_clearGrow.st1.s109.next DEC_clearGrow.st1.s110.next)
kernel_rfl DEC_clearGrow.st1.fb109 : footRB DEC_clearGrow.st1.s109 DEC_clearGrow.st1.s110 DEC_clearGrow.st1.fR109 = true
kernel_rfl DEC_clearGrow.st1.fc109 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s109.next && Nat.ble DEC_clearGrow.st1.s110.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR109 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa110 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s110 :=
  DEC_clearGrow.st1.fa109.step (stageFoot_ofRF DEC_clearGrow.st1.fh109 DEC_clearGrow.st1.fb109) (incl_of_footW DEC_clearGrow.st1.fb109 DEC_clearGrow.st1.fc109)

def DEC_clearGrow.st1.fR110 : List (Nat × Nat) := [(3123796, 3123797), (3230485, 3230486), (3230551, 3230552), (3232165, 3232166), (3232219, 3232220), (3232225, 3232226), (3232231, 3232232), (3232485, 3232486), (3232506, 3232507), (3232556, 3232557), (3232578, 3232580), (3232717, 3232718)]
kernel_rfl DEC_clearGrow.st1.fh110 : DEC_clearGrow.st1.s111.heap = setAll DEC_clearGrow.st1.s110.heap (rangesOf DEC_clearGrow.st1.s111.heap DEC_clearGrow.st1.fR110 ++ freshOf DEC_clearGrow.st1.s111.heap DEC_clearGrow.st1.s110.next DEC_clearGrow.st1.s111.next)
kernel_rfl DEC_clearGrow.st1.fb110 : footRB DEC_clearGrow.st1.s110 DEC_clearGrow.st1.s111 DEC_clearGrow.st1.fR110 = true
kernel_rfl DEC_clearGrow.st1.fc110 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s110.next && Nat.ble DEC_clearGrow.st1.s111.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR110 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa111 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s111 :=
  DEC_clearGrow.st1.fa110.step (stageFoot_ofRF DEC_clearGrow.st1.fh110 DEC_clearGrow.st1.fb110) (incl_of_footW DEC_clearGrow.st1.fb110 DEC_clearGrow.st1.fc110)

def DEC_clearGrow.st1.fR111 : List (Nat × Nat) := [(2672651, 2672652), (3083774, 3083775), (3084203, 3084204), (3232919, 3232922), (3232967, 3232972), (3233161, 3233162), (3233386, 3233387), (3233472, 3233473), (3233561, 3233562), (3233599, 3233606), (3233645, 3233647), (3233699, 3233700), (3233724, 3233725), (3233768, 3233770)]
kernel_rfl DEC_clearGrow.st1.fh111 : DEC_clearGrow.st1.s112.heap = setAll DEC_clearGrow.st1.s111.heap (rangesOf DEC_clearGrow.st1.s112.heap DEC_clearGrow.st1.fR111 ++ freshOf DEC_clearGrow.st1.s112.heap DEC_clearGrow.st1.s111.next DEC_clearGrow.st1.s112.next)
kernel_rfl DEC_clearGrow.st1.fb111 : footRB DEC_clearGrow.st1.s111 DEC_clearGrow.st1.s112 DEC_clearGrow.st1.fR111 = true
kernel_rfl DEC_clearGrow.st1.fc111 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s111.next && Nat.ble DEC_clearGrow.st1.s112.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR111 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa112 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s112 :=
  DEC_clearGrow.st1.fa111.step (stageFoot_ofRF DEC_clearGrow.st1.fh111 DEC_clearGrow.st1.fb111) (incl_of_footW DEC_clearGrow.st1.fb111 DEC_clearGrow.st1.fc111)

def DEC_clearGrow.st1.fR112 : List (Nat × Nat) := [(3123796, 3123797), (3232881, 3232882), (3232947, 3232948), (3234561, 3234562), (3234615, 3234616), (3234621, 3234622), (3234627, 3234628), (3234635, 3234636), (3234647, 3234650), (3234704, 3234705)]
kernel_rfl DEC_clearGrow.st1.fh112 : DEC_clearGrow.st1.s113.heap = setAll DEC_clearGrow.st1.s112.heap (rangesOf DEC_clearGrow.st1.s113.heap DEC_clearGrow.st1.fR112 ++ freshOf DEC_clearGrow.st1.s113.heap DEC_clearGrow.st1.s112.next DEC_clearGrow.st1.s113.next)
kernel_rfl DEC_clearGrow.st1.fb112 : footRB DEC_clearGrow.st1.s112 DEC_clearGrow.st1.s113 DEC_clearGrow.st1.fR112 = true
kernel_rfl DEC_clearGrow.st1.fc112 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s112.next && Nat.ble DEC_clearGrow.st1.s113.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR112 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa113 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s113 :=
  DEC_clearGrow.st1.fa112.step (stageFoot_ofRF DEC_clearGrow.st1.fh112 DEC_clearGrow.st1.fb112) (incl_of_footW DEC_clearGrow.st1.fb112 DEC_clearGrow.st1.fc112)

def DEC_clearGrow.st1.fR113 : List (Nat × Nat) := [(4841, 4842), (2672663, 2672664), (3086262, 3086263), (3086314, 3086315), (3235378, 3235384), (3235610, 3235611), (3235674, 3235675)]
kernel_rfl DEC_clearGrow.st1.fh113 : DEC_clearGrow.st1.s114.heap = setAll DEC_clearGrow.st1.s113.heap (rangesOf DEC_clearGrow.st1.s114.heap DEC_clearGrow.st1.fR113 ++ freshOf DEC_clearGrow.st1.s114.heap DEC_clearGrow.st1.s113.next DEC_clearGrow.st1.s114.next)
kernel_rfl DEC_clearGrow.st1.fb113 : footRB DEC_clearGrow.st1.s113 DEC_clearGrow.st1.s114 DEC_clearGrow.st1.fR113 = true
kernel_rfl DEC_clearGrow.st1.fc113 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s113.next && Nat.ble DEC_clearGrow.st1.s114.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR113 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa114 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s114 :=
  DEC_clearGrow.st1.fa113.step (stageFoot_ofRF DEC_clearGrow.st1.fh113 DEC_clearGrow.st1.fb113) (incl_of_footW DEC_clearGrow.st1.fb113 DEC_clearGrow.st1.fc113)

def DEC_clearGrow.st1.fR114 : List (Nat × Nat) := [(3123796, 3123797), (3235277, 3235278), (3235316, 3235319), (3235344, 3235345), (3235384, 3235389), (3235705, 3235706), (3236150, 3236151), (3236674, 3236675), (3236723, 3236724)]
kernel_rfl DEC_clearGrow.st1.fh114 : DEC_clearGrow.st1.s115.heap = setAll DEC_clearGrow.st1.s114.heap (rangesOf DEC_clearGrow.st1.s115.heap DEC_clearGrow.st1.fR114 ++ freshOf DEC_clearGrow.st1.s115.heap DEC_clearGrow.st1.s114.next DEC_clearGrow.st1.s115.next)
kernel_rfl DEC_clearGrow.st1.fb114 : footRB DEC_clearGrow.st1.s114 DEC_clearGrow.st1.s115 DEC_clearGrow.st1.fR114 = true
kernel_rfl DEC_clearGrow.st1.fc114 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s114.next && Nat.ble DEC_clearGrow.st1.s115.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR114 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa115 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s115 :=
  DEC_clearGrow.st1.fa114.step (stageFoot_ofRF DEC_clearGrow.st1.fh114 DEC_clearGrow.st1.fb114) (incl_of_footW DEC_clearGrow.st1.fb114 DEC_clearGrow.st1.fc114)

def DEC_clearGrow.st1.fR115 : List (Nat × Nat) := [(2672672, 2672673), (3088372, 3088373)]
kernel_rfl DEC_clearGrow.st1.fh115 : DEC_clearGrow.st1.s116.heap = setAll DEC_clearGrow.st1.s115.heap (rangesOf DEC_clearGrow.st1.s116.heap DEC_clearGrow.st1.fR115 ++ freshOf DEC_clearGrow.st1.s116.heap DEC_clearGrow.st1.s115.next DEC_clearGrow.st1.s116.next)
kernel_rfl DEC_clearGrow.st1.fb115 : footRB DEC_clearGrow.st1.s115 DEC_clearGrow.st1.s116 DEC_clearGrow.st1.fR115 = true
kernel_rfl DEC_clearGrow.st1.fc115 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s115.next && Nat.ble DEC_clearGrow.st1.s116.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR115 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa116 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s116 :=
  DEC_clearGrow.st1.fa115.step (stageFoot_ofRF DEC_clearGrow.st1.fh115 DEC_clearGrow.st1.fb115) (incl_of_footW DEC_clearGrow.st1.fb115 DEC_clearGrow.st1.fc115)

def DEC_clearGrow.st1.fR116 : List (Nat × Nat) := [(2672672, 2672673), (3088801, 3088802), (3237713, 3237716), (3237761, 3237766), (3237955, 3237956), (3238180, 3238181), (3238266, 3238267), (3238355, 3238356), (3238398, 3238400), (3238721, 3238722), (3238727, 3238728), (3238733, 3238734)]
kernel_rfl DEC_clearGrow.st1.fh116 : DEC_clearGrow.st1.s117.heap = setAll DEC_clearGrow.st1.s116.heap (rangesOf DEC_clearGrow.st1.s117.heap DEC_clearGrow.st1.fR116 ++ freshOf DEC_clearGrow.st1.s117.heap DEC_clearGrow.st1.s116.next DEC_clearGrow.st1.s117.next)
kernel_rfl DEC_clearGrow.st1.fb116 : footRB DEC_clearGrow.st1.s116 DEC_clearGrow.st1.s117 DEC_clearGrow.st1.fR116 = true
kernel_rfl DEC_clearGrow.st1.fc116 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s116.next && Nat.ble DEC_clearGrow.st1.s117.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR116 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa117 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s117 :=
  DEC_clearGrow.st1.fa116.step (stageFoot_ofRF DEC_clearGrow.st1.fh116 DEC_clearGrow.st1.fb116) (incl_of_footW DEC_clearGrow.st1.fb116 DEC_clearGrow.st1.fc116)

def DEC_clearGrow.st1.fR117 : List (Nat × Nat) := [(3123796, 3123797), (3237653, 3237654), (3237741, 3237742), (3239355, 3239356), (3239409, 3239410), (3239415, 3239416), (3239421, 3239422), (3239429, 3239430), (3239443, 3239444), (3239644, 3239645), (3239668, 3239669)]
kernel_rfl DEC_clearGrow.st1.fh117 : DEC_clearGrow.st1.s118.heap = setAll DEC_clearGrow.st1.s117.heap (rangesOf DEC_clearGrow.st1.s118.heap DEC_clearGrow.st1.fR117 ++ freshOf DEC_clearGrow.st1.s118.heap DEC_clearGrow.st1.s117.next DEC_clearGrow.st1.s118.next)
kernel_rfl DEC_clearGrow.st1.fb117 : footRB DEC_clearGrow.st1.s117 DEC_clearGrow.st1.s118 DEC_clearGrow.st1.fR117 = true
kernel_rfl DEC_clearGrow.st1.fc117 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s117.next && Nat.ble DEC_clearGrow.st1.s118.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR117 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa118 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s118 :=
  DEC_clearGrow.st1.fa117.step (stageFoot_ofRF DEC_clearGrow.st1.fh117 DEC_clearGrow.st1.fb117) (incl_of_footW DEC_clearGrow.st1.fb117 DEC_clearGrow.st1.fc117)

def DEC_clearGrow.st1.fR118 : List (Nat × Nat) := [(2672677, 2672678), (3090768, 3090769), (3091197, 3091198), (3240154, 3240161), (3240351, 3240352), (3240576, 3240577), (3240589, 3240590), (3240662, 3240663)]
kernel_rfl DEC_clearGrow.st1.fh118 : DEC_clearGrow.st1.s119.heap = setAll DEC_clearGrow.st1.s118.heap (rangesOf DEC_clearGrow.st1.s119.heap DEC_clearGrow.st1.fR118 ++ freshOf DEC_clearGrow.st1.s119.heap DEC_clearGrow.st1.s118.next DEC_clearGrow.st1.s119.next)
kernel_rfl DEC_clearGrow.st1.fb118 : footRB DEC_clearGrow.st1.s118 DEC_clearGrow.st1.s119 DEC_clearGrow.st1.fR118 = true
kernel_rfl DEC_clearGrow.st1.fc118 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s118.next && Nat.ble DEC_clearGrow.st1.s119.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR118 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa119 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s119 :=
  DEC_clearGrow.st1.fa118.step (stageFoot_ofRF DEC_clearGrow.st1.fh118 DEC_clearGrow.st1.fb118) (incl_of_footW DEC_clearGrow.st1.fb118 DEC_clearGrow.st1.fc118)

def DEC_clearGrow.st1.fR119 : List (Nat × Nat) := [(3123796, 3123797), (3240071, 3240072), (3240109, 3240112), (3240137, 3240138), (3240161, 3240162), (3241568, 3241569), (3241593, 3241594), (3241661, 3241662), (3241664, 3241674)]
kernel_rfl DEC_clearGrow.st1.fh119 : DEC_clearGrow.st1.s120.heap = setAll DEC_clearGrow.st1.s119.heap (rangesOf DEC_clearGrow.st1.s120.heap DEC_clearGrow.st1.fR119 ++ freshOf DEC_clearGrow.st1.s120.heap DEC_clearGrow.st1.s119.next DEC_clearGrow.st1.s120.next)
kernel_rfl DEC_clearGrow.st1.fb119 : footRB DEC_clearGrow.st1.s119 DEC_clearGrow.st1.s120 DEC_clearGrow.st1.fR119 = true
kernel_rfl DEC_clearGrow.st1.fc119 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s119.next && Nat.ble DEC_clearGrow.st1.s120.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR119 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa120 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s120 :=
  DEC_clearGrow.st1.fa119.step (stageFoot_ofRF DEC_clearGrow.st1.fh119 DEC_clearGrow.st1.fb119) (incl_of_footW DEC_clearGrow.st1.fb119 DEC_clearGrow.st1.fc119)

def DEC_clearGrow.st1.fR120 : List (Nat × Nat) := [(2672682, 2672683), (3093164, 3093165), (3242548, 3242553), (3242589, 3242590), (3242621, 3242623)]
kernel_rfl DEC_clearGrow.st1.fh120 : DEC_clearGrow.st1.s121.heap = setAll DEC_clearGrow.st1.s120.heap (rangesOf DEC_clearGrow.st1.s121.heap DEC_clearGrow.st1.fR120 ++ freshOf DEC_clearGrow.st1.s121.heap DEC_clearGrow.st1.s120.next DEC_clearGrow.st1.s121.next)
kernel_rfl DEC_clearGrow.st1.fb120 : footRB DEC_clearGrow.st1.s120 DEC_clearGrow.st1.s121 DEC_clearGrow.st1.fR120 = true
kernel_rfl DEC_clearGrow.st1.fc120 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s120.next && Nat.ble DEC_clearGrow.st1.s121.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR120 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa121 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s121 :=
  DEC_clearGrow.st1.fa120.step (stageFoot_ofRF DEC_clearGrow.st1.fh120 DEC_clearGrow.st1.fb120) (incl_of_footW DEC_clearGrow.st1.fb120 DEC_clearGrow.st1.fc120)

def DEC_clearGrow.st1.fR121 : List (Nat × Nat) := [(2672682, 2672683), (3093593, 3093594), (3242505, 3242508), (3242553, 3242558), (3242747, 3242748), (3242972, 3242973), (3243058, 3243059), (3243147, 3243148), (3243190, 3243192), (3243513, 3243514), (3243519, 3243520), (3243525, 3243526), (3243554, 3243556), (3243600, 3243601), (3243644, 3243645), (3243662, 3243668), (3243684, 3243685)]
kernel_rfl DEC_clearGrow.st1.fh121 : DEC_clearGrow.st1.s122.heap = setAll DEC_clearGrow.st1.s121.heap (rangesOf DEC_clearGrow.st1.s122.heap DEC_clearGrow.st1.fR121 ++ freshOf DEC_clearGrow.st1.s122.heap DEC_clearGrow.st1.s121.next DEC_clearGrow.st1.s122.next)
kernel_rfl DEC_clearGrow.st1.fb121 : footRB DEC_clearGrow.st1.s121 DEC_clearGrow.st1.s122 DEC_clearGrow.st1.fR121 = true
kernel_rfl DEC_clearGrow.st1.fc121 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s121.next && Nat.ble DEC_clearGrow.st1.s122.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR121 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa122 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s122 :=
  DEC_clearGrow.st1.fa121.step (stageFoot_ofRF DEC_clearGrow.st1.fh121 DEC_clearGrow.st1.fb121) (incl_of_footW DEC_clearGrow.st1.fb121 DEC_clearGrow.st1.fc121)

def DEC_clearGrow.st1.fR122 : List (Nat × Nat) := [(3123796, 3123797), (3242467, 3242468), (3242533, 3242534), (3244147, 3244148), (3244201, 3244202), (3244207, 3244208), (3244213, 3244214), (3244467, 3244468), (3244488, 3244489), (3244538, 3244539), (3244556, 3244558), (3244590, 3244591), (3244593, 3244603)]
kernel_rfl DEC_clearGrow.st1.fh122 : DEC_clearGrow.st1.s123.heap = setAll DEC_clearGrow.st1.s122.heap (rangesOf DEC_clearGrow.st1.s123.heap DEC_clearGrow.st1.fR122 ++ freshOf DEC_clearGrow.st1.s123.heap DEC_clearGrow.st1.s122.next DEC_clearGrow.st1.s123.next)
kernel_rfl DEC_clearGrow.st1.fb122 : footRB DEC_clearGrow.st1.s122 DEC_clearGrow.st1.s123 DEC_clearGrow.st1.fR122 = true
kernel_rfl DEC_clearGrow.st1.fc122 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s122.next && Nat.ble DEC_clearGrow.st1.s123.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR122 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa123 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s123 :=
  DEC_clearGrow.st1.fa122.step (stageFoot_ofRF DEC_clearGrow.st1.fh122 DEC_clearGrow.st1.fb122) (incl_of_footW DEC_clearGrow.st1.fb122 DEC_clearGrow.st1.fc122)

def DEC_clearGrow.st1.fR123 : List (Nat × Nat) := [(4841, 4842), (2672694, 2672695), (3095648, 3095649), (3095700, 3095701), (3244898, 3244901), (3244961, 3244971), (3245287, 3245288), (3245462, 3245463), (3245530, 3245531), (3245598, 3245599), (3245622, 3245625), (3245626, 3245627)]
kernel_rfl DEC_clearGrow.st1.fh123 : DEC_clearGrow.st1.s124.heap = setAll DEC_clearGrow.st1.s123.heap (rangesOf DEC_clearGrow.st1.s124.heap DEC_clearGrow.st1.fR123 ++ freshOf DEC_clearGrow.st1.s124.heap DEC_clearGrow.st1.s123.next DEC_clearGrow.st1.s124.next)
kernel_rfl DEC_clearGrow.st1.fb123 : footRB DEC_clearGrow.st1.s123 DEC_clearGrow.st1.s124 DEC_clearGrow.st1.fR123 = true
kernel_rfl DEC_clearGrow.st1.fc123 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s123.next && Nat.ble DEC_clearGrow.st1.s124.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR123 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa124 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s124 :=
  DEC_clearGrow.st1.fa123.step (stageFoot_ofRF DEC_clearGrow.st1.fh123 DEC_clearGrow.st1.fb123) (incl_of_footW DEC_clearGrow.st1.fb123 DEC_clearGrow.st1.fc123)

def DEC_clearGrow.st1.fR124 : List (Nat × Nat) := [(3123796, 3123797), (3244859, 3244860), (3244926, 3244927), (3246515, 3246516), (3246573, 3246574), (3246579, 3246580), (3246585, 3246586), (3246593, 3246594), (3246604, 3246608)]
kernel_rfl DEC_clearGrow.st1.fh124 : DEC_clearGrow.st1.s125.heap = setAll DEC_clearGrow.st1.s124.heap (rangesOf DEC_clearGrow.st1.s125.heap DEC_clearGrow.st1.fR124 ++ freshOf DEC_clearGrow.st1.s125.heap DEC_clearGrow.st1.s124.next DEC_clearGrow.st1.s125.next)
kernel_rfl DEC_clearGrow.st1.fb124 : footRB DEC_clearGrow.st1.s124 DEC_clearGrow.st1.s125 DEC_clearGrow.st1.fR124 = true
kernel_rfl DEC_clearGrow.st1.fc124 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s124.next && Nat.ble DEC_clearGrow.st1.s125.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR124 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa125 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s125 :=
  DEC_clearGrow.st1.fa124.step (stageFoot_ofRF DEC_clearGrow.st1.fh124 DEC_clearGrow.st1.fb124) (incl_of_footW DEC_clearGrow.st1.fb124 DEC_clearGrow.st1.fc124)

def DEC_clearGrow.st1.fR125 : List (Nat × Nat) := [(2672703, 2672704), (3097754, 3097755), (3247335, 3247339), (3247564, 3247565), (3247596, 3247597), (3247620, 3247621)]
kernel_rfl DEC_clearGrow.st1.fh125 : DEC_clearGrow.st1.s126.heap = setAll DEC_clearGrow.st1.s125.heap (rangesOf DEC_clearGrow.st1.s126.heap DEC_clearGrow.st1.fR125 ++ freshOf DEC_clearGrow.st1.s126.heap DEC_clearGrow.st1.s125.next DEC_clearGrow.st1.s126.next)
kernel_rfl DEC_clearGrow.st1.fb125 : footRB DEC_clearGrow.st1.s125 DEC_clearGrow.st1.s126 DEC_clearGrow.st1.fR125 = true
kernel_rfl DEC_clearGrow.st1.fc125 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s125.next && Nat.ble DEC_clearGrow.st1.s126.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR125 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa126 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s126 :=
  DEC_clearGrow.st1.fa125.step (stageFoot_ofRF DEC_clearGrow.st1.fh125 DEC_clearGrow.st1.fb125) (incl_of_footW DEC_clearGrow.st1.fb125 DEC_clearGrow.st1.fc125)

def DEC_clearGrow.st1.fR126 : List (Nat × Nat) := [(2672703, 2672704), (3098183, 3098184), (3247291, 3247294), (3247339, 3247344), (3247533, 3247534), (3247758, 3247759), (3247844, 3247845), (3247933, 3247934), (3247976, 3247978), (3248299, 3248300), (3248305, 3248306), (3248311, 3248312), (3248340, 3248342), (3248386, 3248387), (3248430, 3248431), (3248631, 3248632)]
kernel_rfl DEC_clearGrow.st1.fh126 : DEC_clearGrow.st1.s127.heap = setAll DEC_clearGrow.st1.s126.heap (rangesOf DEC_clearGrow.st1.s127.heap DEC_clearGrow.st1.fR126 ++ freshOf DEC_clearGrow.st1.s127.heap DEC_clearGrow.st1.s126.next DEC_clearGrow.st1.s127.next)
kernel_rfl DEC_clearGrow.st1.fb126 : footRB DEC_clearGrow.st1.s126 DEC_clearGrow.st1.s127 DEC_clearGrow.st1.fR126 = true
kernel_rfl DEC_clearGrow.st1.fc126 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s126.next && Nat.ble DEC_clearGrow.st1.s127.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR126 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa127 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s127 :=
  DEC_clearGrow.st1.fa126.step (stageFoot_ofRF DEC_clearGrow.st1.fh126 DEC_clearGrow.st1.fb126) (incl_of_footW DEC_clearGrow.st1.fb126 DEC_clearGrow.st1.fc126)

def DEC_clearGrow.st1.fR127 : List (Nat × Nat) := [(2672708, 2672709), (3100046, 3100047), (3123796, 3123797), (3247231, 3247232), (3247319, 3247320), (3248933, 3248934), (3248987, 3248988), (3248993, 3248994), (3248999, 3249000), (3249253, 3249254), (3249274, 3249275), (3249324, 3249325), (3249343, 3249344), (3249486, 3249487), (3249564, 3249566)]
kernel_rfl DEC_clearGrow.st1.fh127 : DEC_clearGrow.st1.s128.heap = setAll DEC_clearGrow.st1.s127.heap (rangesOf DEC_clearGrow.st1.s128.heap DEC_clearGrow.st1.fR127 ++ freshOf DEC_clearGrow.st1.s128.heap DEC_clearGrow.st1.s127.next DEC_clearGrow.st1.s128.next)
kernel_rfl DEC_clearGrow.st1.fb127 : footRB DEC_clearGrow.st1.s127 DEC_clearGrow.st1.s128 DEC_clearGrow.st1.fR127 = true
kernel_rfl DEC_clearGrow.st1.fc127 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s127.next && Nat.ble DEC_clearGrow.st1.s128.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR127 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa128 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s128 :=
  DEC_clearGrow.st1.fa127.step (stageFoot_ofRF DEC_clearGrow.st1.fh127 DEC_clearGrow.st1.fb127) (incl_of_footW DEC_clearGrow.st1.fb127 DEC_clearGrow.st1.fc127)

end Host.Load.Run.Tpl

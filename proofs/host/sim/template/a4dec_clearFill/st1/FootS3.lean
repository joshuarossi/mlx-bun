import host.sim.template.a4dec_clearFill.st1.FootS2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearFill.st1.fR96 : List (Nat × Nat) := [(3123796, 3123797), (3216541, 3216542), (3216629, 3216630), (3218243, 3218244), (3218297, 3218298), (3218303, 3218304), (3218309, 3218310), (3218563, 3218564), (3218584, 3218585), (3218634, 3218635), (3218652, 3218654), (3218686, 3218687), (3218689, 3218699), (3218771, 3218772)]
kernel_rfl DEC_clearFill.st1.fh96 : DEC_clearFill.st1.s97.heap = setAll DEC_clearFill.st1.s96.heap (rangesOf DEC_clearFill.st1.s97.heap DEC_clearFill.st1.fR96 ++ freshOf DEC_clearFill.st1.s97.heap DEC_clearFill.st1.s96.next DEC_clearFill.st1.s97.next)
kernel_rfl DEC_clearFill.st1.fb96 : footRB DEC_clearFill.st1.s96 DEC_clearFill.st1.s97 DEC_clearFill.st1.fR96 = true
kernel_rfl DEC_clearFill.st1.fc96 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s96.next && Nat.ble DEC_clearFill.st1.s97.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR96 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa97 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s97 :=
  DEC_clearFill.st1.fa96.step (stageFoot_ofRF DEC_clearFill.st1.fh96 DEC_clearFill.st1.fb96) (incl_of_footW DEC_clearFill.st1.fb96 DEC_clearFill.st1.fc96)

def DEC_clearFill.st1.fR97 : List (Nat × Nat) := [(2672615, 2672616), (3072004, 3072005), (3072433, 3072434), (3218993, 3218996), (3219041, 3219046), (3219235, 3219236), (3219460, 3219461), (3219546, 3219547), (3219635, 3219636), (3219673, 3219680), (3219719, 3219721), (3219773, 3219774)]
kernel_rfl DEC_clearFill.st1.fh97 : DEC_clearFill.st1.s98.heap = setAll DEC_clearFill.st1.s97.heap (rangesOf DEC_clearFill.st1.s98.heap DEC_clearFill.st1.fR97 ++ freshOf DEC_clearFill.st1.s98.heap DEC_clearFill.st1.s97.next DEC_clearFill.st1.s98.next)
kernel_rfl DEC_clearFill.st1.fb97 : footRB DEC_clearFill.st1.s97 DEC_clearFill.st1.s98 DEC_clearFill.st1.fR97 = true
kernel_rfl DEC_clearFill.st1.fc97 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s97.next && Nat.ble DEC_clearFill.st1.s98.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR97 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa98 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s98 :=
  DEC_clearFill.st1.fa97.step (stageFoot_ofRF DEC_clearFill.st1.fh97 DEC_clearFill.st1.fb97) (incl_of_footW DEC_clearFill.st1.fb97 DEC_clearFill.st1.fc97)

def DEC_clearFill.st1.fR98 : List (Nat × Nat) := [(3123796, 3123797), (3218955, 3218956), (3219021, 3219022), (3220635, 3220636), (3220689, 3220690), (3220695, 3220696), (3220701, 3220702), (3220709, 3220710), (3220720, 3220724)]
kernel_rfl DEC_clearFill.st1.fh98 : DEC_clearFill.st1.s99.heap = setAll DEC_clearFill.st1.s98.heap (rangesOf DEC_clearFill.st1.s99.heap DEC_clearFill.st1.fR98 ++ freshOf DEC_clearFill.st1.s99.heap DEC_clearFill.st1.s98.next DEC_clearFill.st1.s99.next)
kernel_rfl DEC_clearFill.st1.fb98 : footRB DEC_clearFill.st1.s98 DEC_clearFill.st1.s99 DEC_clearFill.st1.fR98 = true
kernel_rfl DEC_clearFill.st1.fc98 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s98.next && Nat.ble DEC_clearFill.st1.s99.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR98 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa99 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s99 :=
  DEC_clearFill.st1.fa98.step (stageFoot_ofRF DEC_clearFill.st1.fh98 DEC_clearFill.st1.fb98) (incl_of_footW DEC_clearFill.st1.fb98 DEC_clearFill.st1.fc98)

def DEC_clearFill.st1.fR99 : List (Nat × Nat) := [(2672620, 2672621), (3074396, 3074397), (3221429, 3221433), (3221658, 3221659), (3221726, 3221727), (3221728, 3221739)]
kernel_rfl DEC_clearFill.st1.fh99 : DEC_clearFill.st1.s100.heap = setAll DEC_clearFill.st1.s99.heap (rangesOf DEC_clearFill.st1.s100.heap DEC_clearFill.st1.fR99 ++ freshOf DEC_clearFill.st1.s100.heap DEC_clearFill.st1.s99.next DEC_clearFill.st1.s100.next)
kernel_rfl DEC_clearFill.st1.fb99 : footRB DEC_clearFill.st1.s99 DEC_clearFill.st1.s100 DEC_clearFill.st1.fR99 = true
kernel_rfl DEC_clearFill.st1.fc99 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s99.next && Nat.ble DEC_clearFill.st1.s100.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR99 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa100 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s100 :=
  DEC_clearFill.st1.fa99.step (stageFoot_ofRF DEC_clearFill.st1.fh99 DEC_clearFill.st1.fb99) (incl_of_footW DEC_clearFill.st1.fb99 DEC_clearFill.st1.fc99)

def DEC_clearFill.st1.fR100 : List (Nat × Nat) := [(2672620, 2672621), (3074825, 3074826), (3221385, 3221388), (3221433, 3221438), (3221627, 3221628), (3221852, 3221853), (3221938, 3221939), (3222027, 3222028), (3222070, 3222072), (3222393, 3222394), (3222399, 3222400), (3222405, 3222406), (3222725, 3222726)]
kernel_rfl DEC_clearFill.st1.fh100 : DEC_clearFill.st1.s101.heap = setAll DEC_clearFill.st1.s100.heap (rangesOf DEC_clearFill.st1.s101.heap DEC_clearFill.st1.fR100 ++ freshOf DEC_clearFill.st1.s101.heap DEC_clearFill.st1.s100.next DEC_clearFill.st1.s101.next)
kernel_rfl DEC_clearFill.st1.fb100 : footRB DEC_clearFill.st1.s100 DEC_clearFill.st1.s101 DEC_clearFill.st1.fR100 = true
kernel_rfl DEC_clearFill.st1.fc100 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s100.next && Nat.ble DEC_clearFill.st1.s101.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR100 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa101 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s101 :=
  DEC_clearFill.st1.fa100.step (stageFoot_ofRF DEC_clearFill.st1.fh100 DEC_clearFill.st1.fb100) (incl_of_footW DEC_clearFill.st1.fb100 DEC_clearFill.st1.fc100)

def DEC_clearFill.st1.fR101 : List (Nat × Nat) := [(4841, 4842), (2672632, 2672633), (3123796, 3123797), (3221347, 3221348), (3221413, 3221414), (3223027, 3223028), (3223081, 3223082), (3223087, 3223088), (3223093, 3223094), (3223347, 3223348), (3223368, 3223369), (3223418, 3223419), (3223437, 3223438), (3223580, 3223581), (3223658, 3223659), (3223663, 3223664)]
kernel_rfl DEC_clearFill.st1.fh101 : DEC_clearFill.st1.s102.heap = setAll DEC_clearFill.st1.s101.heap (rangesOf DEC_clearFill.st1.s102.heap DEC_clearFill.st1.fR101 ++ freshOf DEC_clearFill.st1.s102.heap DEC_clearFill.st1.s101.next DEC_clearFill.st1.s102.next)
kernel_rfl DEC_clearFill.st1.fb101 : footRB DEC_clearFill.st1.s101 DEC_clearFill.st1.s102 DEC_clearFill.st1.fR101 = true
kernel_rfl DEC_clearFill.st1.fc101 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s101.next && Nat.ble DEC_clearFill.st1.s102.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR101 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa102 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s102 :=
  DEC_clearFill.st1.fa101.step (stageFoot_ofRF DEC_clearFill.st1.fh101 DEC_clearFill.st1.fb101) (incl_of_footW DEC_clearFill.st1.fb101 DEC_clearFill.st1.fc101)

def DEC_clearFill.st1.fR102 : List (Nat × Nat) := [(2672632, 2672633), (3076880, 3076881), (3076932, 3076933), (3223778, 3223781), (3223844, 3223851), (3224167, 3224168), (3224577, 3224578), (3224612, 3224613), (3224647, 3224648), (3224672, 3224674), (3224684, 3224687), (3224728, 3224730)]
kernel_rfl DEC_clearFill.st1.fh102 : DEC_clearFill.st1.s103.heap = setAll DEC_clearFill.st1.s102.heap (rangesOf DEC_clearFill.st1.s103.heap DEC_clearFill.st1.fR102 ++ freshOf DEC_clearFill.st1.s103.heap DEC_clearFill.st1.s102.next DEC_clearFill.st1.s103.next)
kernel_rfl DEC_clearFill.st1.fb102 : footRB DEC_clearFill.st1.s102 DEC_clearFill.st1.s103 DEC_clearFill.st1.fR102 = true
kernel_rfl DEC_clearFill.st1.fc102 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s102.next && Nat.ble DEC_clearFill.st1.s103.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR102 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa103 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s103 :=
  DEC_clearFill.st1.fa102.step (stageFoot_ofRF DEC_clearFill.st1.fh102 DEC_clearFill.st1.fb102) (incl_of_footW DEC_clearFill.st1.fb102 DEC_clearFill.st1.fc102)

def DEC_clearFill.st1.fR103 : List (Nat × Nat) := [(3123796, 3123797), (3223739, 3223740), (3223806, 3223807), (3225199, 3225200), (3225257, 3225258), (3225263, 3225264), (3225269, 3225270), (3225523, 3225524), (3225544, 3225545), (3225594, 3225595), (3225612, 3225614), (3225646, 3225647), (3225649, 3225659)]
kernel_rfl DEC_clearFill.st1.fh103 : DEC_clearFill.st1.s104.heap = setAll DEC_clearFill.st1.s103.heap (rangesOf DEC_clearFill.st1.s104.heap DEC_clearFill.st1.fR103 ++ freshOf DEC_clearFill.st1.s104.heap DEC_clearFill.st1.s103.next DEC_clearFill.st1.s104.next)
kernel_rfl DEC_clearFill.st1.fb103 : footRB DEC_clearFill.st1.s103 DEC_clearFill.st1.s104 DEC_clearFill.st1.fR103 = true
kernel_rfl DEC_clearFill.st1.fc103 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s103.next && Nat.ble DEC_clearFill.st1.s104.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR103 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa104 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s104 :=
  DEC_clearFill.st1.fa103.step (stageFoot_ofRF DEC_clearFill.st1.fh103 DEC_clearFill.st1.fb103) (incl_of_footW DEC_clearFill.st1.fb103 DEC_clearFill.st1.fc103)

def DEC_clearFill.st1.fR104 : List (Nat × Nat) := [(2672641, 2672642), (3078986, 3078987), (3079415, 3079416), (3225975, 3225976), (3226023, 3226028), (3226217, 3226218), (3226442, 3226443), (3226528, 3226529), (3226617, 3226618), (3226655, 3226662), (3226700, 3226703), (3226721, 3226723), (3226729, 3226730)]
kernel_rfl DEC_clearFill.st1.fh104 : DEC_clearFill.st1.s105.heap = setAll DEC_clearFill.st1.s104.heap (rangesOf DEC_clearFill.st1.s105.heap DEC_clearFill.st1.fR104 ++ freshOf DEC_clearFill.st1.s105.heap DEC_clearFill.st1.s104.next DEC_clearFill.st1.s105.next)
kernel_rfl DEC_clearFill.st1.fb104 : footRB DEC_clearFill.st1.s104 DEC_clearFill.st1.s105 DEC_clearFill.st1.fR104 = true
kernel_rfl DEC_clearFill.st1.fc104 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s104.next && Nat.ble DEC_clearFill.st1.s105.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR104 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa105 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s105 :=
  DEC_clearFill.st1.fa104.step (stageFoot_ofRF DEC_clearFill.st1.fh104 DEC_clearFill.st1.fb104) (incl_of_footW DEC_clearFill.st1.fb104 DEC_clearFill.st1.fc104)

def DEC_clearFill.st1.fR105 : List (Nat × Nat) := [(3123796, 3123797), (3225915, 3225916), (3225976, 3225978), (3226003, 3226004), (3227617, 3227618), (3227666, 3227668), (3227671, 3227672)]
kernel_rfl DEC_clearFill.st1.fh105 : DEC_clearFill.st1.s106.heap = setAll DEC_clearFill.st1.s105.heap (rangesOf DEC_clearFill.st1.s106.heap DEC_clearFill.st1.fR105 ++ freshOf DEC_clearFill.st1.s106.heap DEC_clearFill.st1.s105.next DEC_clearFill.st1.s106.next)
kernel_rfl DEC_clearFill.st1.fb105 : footRB DEC_clearFill.st1.s105 DEC_clearFill.st1.s106 DEC_clearFill.st1.fR105 = true
kernel_rfl DEC_clearFill.st1.fc105 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s105.next && Nat.ble DEC_clearFill.st1.s106.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR105 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa106 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s106 :=
  DEC_clearFill.st1.fa105.step (stageFoot_ofRF DEC_clearFill.st1.fh105 DEC_clearFill.st1.fb105) (incl_of_footW DEC_clearFill.st1.fb105 DEC_clearFill.st1.fc105)

def DEC_clearFill.st1.fR106 : List (Nat × Nat) := [(2672646, 2672647), (3081378, 3081379), (3228411, 3228415), (3228639, 3228641), (3228660, 3228662)]
kernel_rfl DEC_clearFill.st1.fh106 : DEC_clearFill.st1.s107.heap = setAll DEC_clearFill.st1.s106.heap (rangesOf DEC_clearFill.st1.s107.heap DEC_clearFill.st1.fR106 ++ freshOf DEC_clearFill.st1.s107.heap DEC_clearFill.st1.s106.next DEC_clearFill.st1.s107.next)
kernel_rfl DEC_clearFill.st1.fb106 : footRB DEC_clearFill.st1.s106 DEC_clearFill.st1.s107 DEC_clearFill.st1.fR106 = true
kernel_rfl DEC_clearFill.st1.fc106 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s106.next && Nat.ble DEC_clearFill.st1.s107.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR106 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa107 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s107 :=
  DEC_clearFill.st1.fa106.step (stageFoot_ofRF DEC_clearFill.st1.fh106 DEC_clearFill.st1.fb106) (incl_of_footW DEC_clearFill.st1.fb106 DEC_clearFill.st1.fc106)

def DEC_clearFill.st1.fR107 : List (Nat × Nat) := [(2672646, 2672647), (3081807, 3081808), (3228367, 3228370), (3228415, 3228420), (3228609, 3228610), (3228834, 3228835), (3228920, 3228921), (3229009, 3229010), (3229052, 3229054), (3229375, 3229376), (3229381, 3229382), (3229387, 3229388), (3229416, 3229418), (3229462, 3229463), (3229506, 3229507), (3229528, 3229530), (3229569, 3229570), (3229611, 3229614)]
kernel_rfl DEC_clearFill.st1.fh107 : DEC_clearFill.st1.s108.heap = setAll DEC_clearFill.st1.s107.heap (rangesOf DEC_clearFill.st1.s108.heap DEC_clearFill.st1.fR107 ++ freshOf DEC_clearFill.st1.s108.heap DEC_clearFill.st1.s107.next DEC_clearFill.st1.s108.next)
kernel_rfl DEC_clearFill.st1.fb107 : footRB DEC_clearFill.st1.s107 DEC_clearFill.st1.s108 DEC_clearFill.st1.fR107 = true
kernel_rfl DEC_clearFill.st1.fc107 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s107.next && Nat.ble DEC_clearFill.st1.s108.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR107 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa108 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s108 :=
  DEC_clearFill.st1.fa107.step (stageFoot_ofRF DEC_clearFill.st1.fh107 DEC_clearFill.st1.fb107) (incl_of_footW DEC_clearFill.st1.fb107 DEC_clearFill.st1.fc107)

def DEC_clearFill.st1.fR108 : List (Nat × Nat) := [(3123796, 3123797), (3228329, 3228330), (3228395, 3228396), (3230009, 3230010), (3230063, 3230064), (3230069, 3230070), (3230075, 3230076), (3230329, 3230330), (3230350, 3230351), (3230400, 3230401), (3230423, 3230424), (3230566, 3230567), (3230595, 3230596), (3230598, 3230608)]
kernel_rfl DEC_clearFill.st1.fh108 : DEC_clearFill.st1.s109.heap = setAll DEC_clearFill.st1.s108.heap (rangesOf DEC_clearFill.st1.s109.heap DEC_clearFill.st1.fR108 ++ freshOf DEC_clearFill.st1.s109.heap DEC_clearFill.st1.s108.next DEC_clearFill.st1.s109.next)
kernel_rfl DEC_clearFill.st1.fb108 : footRB DEC_clearFill.st1.s108 DEC_clearFill.st1.s109 DEC_clearFill.st1.fR108 = true
kernel_rfl DEC_clearFill.st1.fc108 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s108.next && Nat.ble DEC_clearFill.st1.s109.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR108 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa109 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s109 :=
  DEC_clearFill.st1.fa108.step (stageFoot_ofRF DEC_clearFill.st1.fh108 DEC_clearFill.st1.fb108) (incl_of_footW DEC_clearFill.st1.fb108 DEC_clearFill.st1.fc108)

def DEC_clearFill.st1.fR109 : List (Nat × Nat) := [(2672651, 2672652), (3083774, 3083775), (3084203, 3084204), (3230763, 3230766), (3230811, 3230816), (3231005, 3231006), (3231230, 3231231), (3231316, 3231317), (3231405, 3231406), (3231443, 3231450), (3231489, 3231491), (3231543, 3231544), (3231625, 3231626), (3231670, 3231672), (3231673, 3231674)]
kernel_rfl DEC_clearFill.st1.fh109 : DEC_clearFill.st1.s110.heap = setAll DEC_clearFill.st1.s109.heap (rangesOf DEC_clearFill.st1.s110.heap DEC_clearFill.st1.fR109 ++ freshOf DEC_clearFill.st1.s110.heap DEC_clearFill.st1.s109.next DEC_clearFill.st1.s110.next)
kernel_rfl DEC_clearFill.st1.fb109 : footRB DEC_clearFill.st1.s109 DEC_clearFill.st1.s110 DEC_clearFill.st1.fR109 = true
kernel_rfl DEC_clearFill.st1.fc109 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s109.next && Nat.ble DEC_clearFill.st1.s110.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR109 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa110 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s110 :=
  DEC_clearFill.st1.fa109.step (stageFoot_ofRF DEC_clearFill.st1.fh109 DEC_clearFill.st1.fb109) (incl_of_footW DEC_clearFill.st1.fb109 DEC_clearFill.st1.fc109)

def DEC_clearFill.st1.fR110 : List (Nat × Nat) := [(3123796, 3123797), (3230725, 3230726), (3230791, 3230792), (3232405, 3232406), (3232459, 3232460), (3232465, 3232466), (3232471, 3232472), (3232479, 3232480), (3232492, 3232494), (3232548, 3232549), (3232576, 3232577), (3232579, 3232589)]
kernel_rfl DEC_clearFill.st1.fh110 : DEC_clearFill.st1.s111.heap = setAll DEC_clearFill.st1.s110.heap (rangesOf DEC_clearFill.st1.s111.heap DEC_clearFill.st1.fR110 ++ freshOf DEC_clearFill.st1.s111.heap DEC_clearFill.st1.s110.next DEC_clearFill.st1.s111.next)
kernel_rfl DEC_clearFill.st1.fb110 : footRB DEC_clearFill.st1.s110 DEC_clearFill.st1.s111 DEC_clearFill.st1.fR110 = true
kernel_rfl DEC_clearFill.st1.fc110 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s110.next && Nat.ble DEC_clearFill.st1.s111.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR110 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa111 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s111 :=
  DEC_clearFill.st1.fa110.step (stageFoot_ofRF DEC_clearFill.st1.fh110 DEC_clearFill.st1.fb110) (incl_of_footW DEC_clearFill.st1.fb110 DEC_clearFill.st1.fc110)

def DEC_clearFill.st1.fR111 : List (Nat × Nat) := [(4841, 4842), (2672663, 2672664), (3086262, 3086263), (3086314, 3086315), (3233160, 3233161), (3233223, 3233233), (3233454, 3233455), (3233549, 3233550), (3233562, 3233563), (3233580, 3233581)]
kernel_rfl DEC_clearFill.st1.fh111 : DEC_clearFill.st1.s112.heap = setAll DEC_clearFill.st1.s111.heap (rangesOf DEC_clearFill.st1.s112.heap DEC_clearFill.st1.fR111 ++ freshOf DEC_clearFill.st1.s112.heap DEC_clearFill.st1.s111.next DEC_clearFill.st1.s112.next)
kernel_rfl DEC_clearFill.st1.fb111 : footRB DEC_clearFill.st1.s111 DEC_clearFill.st1.s112 DEC_clearFill.st1.fR111 = true
kernel_rfl DEC_clearFill.st1.fc111 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s111.next && Nat.ble DEC_clearFill.st1.s112.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR111 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa112 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s112 :=
  DEC_clearFill.st1.fa111.step (stageFoot_ofRF DEC_clearFill.st1.fh111 DEC_clearFill.st1.fb111) (incl_of_footW DEC_clearFill.st1.fb111 DEC_clearFill.st1.fc111)

def DEC_clearFill.st1.fR112 : List (Nat × Nat) := [(3123796, 3123797), (3233121, 3233122), (3233161, 3233163), (3233188, 3233189), (3234581, 3234582), (3234609, 3234618)]
kernel_rfl DEC_clearFill.st1.fh112 : DEC_clearFill.st1.s113.heap = setAll DEC_clearFill.st1.s112.heap (rangesOf DEC_clearFill.st1.s113.heap DEC_clearFill.st1.fR112 ++ freshOf DEC_clearFill.st1.s113.heap DEC_clearFill.st1.s112.next DEC_clearFill.st1.s113.next)
kernel_rfl DEC_clearFill.st1.fb112 : footRB DEC_clearFill.st1.s112 DEC_clearFill.st1.s113 DEC_clearFill.st1.fR112 = true
kernel_rfl DEC_clearFill.st1.fc112 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s112.next && Nat.ble DEC_clearFill.st1.s113.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR112 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa113 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s113 :=
  DEC_clearFill.st1.fa112.step (stageFoot_ofRF DEC_clearFill.st1.fh112 DEC_clearFill.st1.fb112) (incl_of_footW DEC_clearFill.st1.fb112 DEC_clearFill.st1.fc112)

def DEC_clearFill.st1.fR113 : List (Nat × Nat) := [(2672672, 2672673), (3088372, 3088373), (3235404, 3235409), (3235445, 3235446), (3235522, 3235526)]
kernel_rfl DEC_clearFill.st1.fh113 : DEC_clearFill.st1.s114.heap = setAll DEC_clearFill.st1.s113.heap (rangesOf DEC_clearFill.st1.s114.heap DEC_clearFill.st1.fR113 ++ freshOf DEC_clearFill.st1.s114.heap DEC_clearFill.st1.s113.next DEC_clearFill.st1.s114.next)
kernel_rfl DEC_clearFill.st1.fb113 : footRB DEC_clearFill.st1.s113 DEC_clearFill.st1.s114 DEC_clearFill.st1.fR113 = true
kernel_rfl DEC_clearFill.st1.fc113 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s113.next && Nat.ble DEC_clearFill.st1.s114.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR113 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa114 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s114 :=
  DEC_clearFill.st1.fa113.step (stageFoot_ofRF DEC_clearFill.st1.fh113 DEC_clearFill.st1.fb113) (incl_of_footW DEC_clearFill.st1.fb113 DEC_clearFill.st1.fc113)

def DEC_clearFill.st1.fR114 : List (Nat × Nat) := [(2672672, 2672673), (3088801, 3088802), (3235361, 3235364), (3235409, 3235414), (3235603, 3235604), (3235828, 3235829), (3235914, 3235915), (3236003, 3236004), (3236046, 3236048), (3236369, 3236370), (3236375, 3236376), (3236381, 3236382), (3236410, 3236412), (3236456, 3236457), (3236500, 3236501), (3236522, 3236524), (3236563, 3236564), (3236595, 3236596), (3236598, 3236608), (3236660, 3236661)]
kernel_rfl DEC_clearFill.st1.fh114 : DEC_clearFill.st1.s115.heap = setAll DEC_clearFill.st1.s114.heap (rangesOf DEC_clearFill.st1.s115.heap DEC_clearFill.st1.fR114 ++ freshOf DEC_clearFill.st1.s115.heap DEC_clearFill.st1.s114.next DEC_clearFill.st1.s115.next)
kernel_rfl DEC_clearFill.st1.fb114 : footRB DEC_clearFill.st1.s114 DEC_clearFill.st1.s115 DEC_clearFill.st1.fR114 = true
kernel_rfl DEC_clearFill.st1.fc114 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s114.next && Nat.ble DEC_clearFill.st1.s115.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR114 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa115 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s115 :=
  DEC_clearFill.st1.fa114.step (stageFoot_ofRF DEC_clearFill.st1.fh114 DEC_clearFill.st1.fb114) (incl_of_footW DEC_clearFill.st1.fb114 DEC_clearFill.st1.fc114)

def DEC_clearFill.st1.fR115 : List (Nat × Nat) := [(3123796, 3123797), (3235301, 3235302), (3235389, 3235390), (3237003, 3237004), (3237057, 3237058), (3237063, 3237064), (3237069, 3237070), (3237323, 3237324), (3237344, 3237345), (3237394, 3237395), (3237416, 3237418), (3237462, 3237463), (3237555, 3237557)]
kernel_rfl DEC_clearFill.st1.fh115 : DEC_clearFill.st1.s116.heap = setAll DEC_clearFill.st1.s115.heap (rangesOf DEC_clearFill.st1.s116.heap DEC_clearFill.st1.fR115 ++ freshOf DEC_clearFill.st1.s116.heap DEC_clearFill.st1.s115.next DEC_clearFill.st1.s116.next)
kernel_rfl DEC_clearFill.st1.fb115 : footRB DEC_clearFill.st1.s115 DEC_clearFill.st1.s116 DEC_clearFill.st1.fR115 = true
kernel_rfl DEC_clearFill.st1.fc115 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s115.next && Nat.ble DEC_clearFill.st1.s116.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR115 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa116 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s116 :=
  DEC_clearFill.st1.fa115.step (stageFoot_ofRF DEC_clearFill.st1.fh115 DEC_clearFill.st1.fb115) (incl_of_footW DEC_clearFill.st1.fb115 DEC_clearFill.st1.fc115)

def DEC_clearFill.st1.fR116 : List (Nat × Nat) := [(2672677, 2672678), (3090768, 3090769), (3091197, 3091198), (3237757, 3237760), (3237805, 3237810), (3237999, 3238000), (3238224, 3238225), (3238310, 3238311), (3238399, 3238400), (3238437, 3238444), (3238483, 3238485), (3238537, 3238538), (3238562, 3238563), (3238585, 3238586), (3238596, 3238597)]
kernel_rfl DEC_clearFill.st1.fh116 : DEC_clearFill.st1.s117.heap = setAll DEC_clearFill.st1.s116.heap (rangesOf DEC_clearFill.st1.s117.heap DEC_clearFill.st1.fR116 ++ freshOf DEC_clearFill.st1.s117.heap DEC_clearFill.st1.s116.next DEC_clearFill.st1.s117.next)
kernel_rfl DEC_clearFill.st1.fb116 : footRB DEC_clearFill.st1.s116 DEC_clearFill.st1.s117 DEC_clearFill.st1.fR116 = true
kernel_rfl DEC_clearFill.st1.fc116 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s116.next && Nat.ble DEC_clearFill.st1.s117.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR116 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa117 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s117 :=
  DEC_clearFill.st1.fa116.step (stageFoot_ofRF DEC_clearFill.st1.fh116 DEC_clearFill.st1.fb116) (incl_of_footW DEC_clearFill.st1.fb116 DEC_clearFill.st1.fc116)

def DEC_clearFill.st1.fR117 : List (Nat × Nat) := [(3123796, 3123797), (3237719, 3237720), (3237785, 3237786), (3239399, 3239400), (3239453, 3239454), (3239459, 3239460), (3239465, 3239466), (3239473, 3239474), (3239485, 3239488), (3239535, 3239536)]
kernel_rfl DEC_clearFill.st1.fh117 : DEC_clearFill.st1.s118.heap = setAll DEC_clearFill.st1.s117.heap (rangesOf DEC_clearFill.st1.s118.heap DEC_clearFill.st1.fR117 ++ freshOf DEC_clearFill.st1.s118.heap DEC_clearFill.st1.s117.next DEC_clearFill.st1.s118.next)
kernel_rfl DEC_clearFill.st1.fb117 : footRB DEC_clearFill.st1.s117 DEC_clearFill.st1.s118 DEC_clearFill.st1.fR117 = true
kernel_rfl DEC_clearFill.st1.fc117 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s117.next && Nat.ble DEC_clearFill.st1.s118.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR117 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa118 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s118 :=
  DEC_clearFill.st1.fa117.step (stageFoot_ofRF DEC_clearFill.st1.fh117 DEC_clearFill.st1.fb117) (incl_of_footW DEC_clearFill.st1.fb117 DEC_clearFill.st1.fc117)

def DEC_clearFill.st1.fR118 : List (Nat × Nat) := [(2672682, 2672683), (3093164, 3093165), (3240197, 3240201), (3240395, 3240396), (3240426, 3240427), (3240494, 3240495), (3240497, 3240507)]
kernel_rfl DEC_clearFill.st1.fh118 : DEC_clearFill.st1.s119.heap = setAll DEC_clearFill.st1.s118.heap (rangesOf DEC_clearFill.st1.s119.heap DEC_clearFill.st1.fR118 ++ freshOf DEC_clearFill.st1.s119.heap DEC_clearFill.st1.s118.next DEC_clearFill.st1.s119.next)
kernel_rfl DEC_clearFill.st1.fb118 : footRB DEC_clearFill.st1.s118 DEC_clearFill.st1.s119 DEC_clearFill.st1.fR118 = true
kernel_rfl DEC_clearFill.st1.fc118 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s118.next && Nat.ble DEC_clearFill.st1.s119.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR118 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa119 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s119 :=
  DEC_clearFill.st1.fa118.step (stageFoot_ofRF DEC_clearFill.st1.fh118 DEC_clearFill.st1.fb118) (incl_of_footW DEC_clearFill.st1.fb118 DEC_clearFill.st1.fc118)

def DEC_clearFill.st1.fR119 : List (Nat × Nat) := [(2672682, 2672683), (3093593, 3093594), (3240153, 3240156), (3240201, 3240206), (3240620, 3240621), (3240706, 3240707), (3241493, 3241494)]
kernel_rfl DEC_clearFill.st1.fh119 : DEC_clearFill.st1.s120.heap = setAll DEC_clearFill.st1.s119.heap (rangesOf DEC_clearFill.st1.s120.heap DEC_clearFill.st1.fR119 ++ freshOf DEC_clearFill.st1.s120.heap DEC_clearFill.st1.s119.next DEC_clearFill.st1.s120.next)
kernel_rfl DEC_clearFill.st1.fb119 : footRB DEC_clearFill.st1.s119 DEC_clearFill.st1.s120 DEC_clearFill.st1.fR119 = true
kernel_rfl DEC_clearFill.st1.fc119 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s119.next && Nat.ble DEC_clearFill.st1.s120.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR119 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa120 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s120 :=
  DEC_clearFill.st1.fa119.step (stageFoot_ofRF DEC_clearFill.st1.fh119 DEC_clearFill.st1.fb119) (incl_of_footW DEC_clearFill.st1.fb119 DEC_clearFill.st1.fc119)

def DEC_clearFill.st1.fR120 : List (Nat × Nat) := [(4841, 4842), (2672694, 2672695), (3123796, 3123797), (3240115, 3240116), (3240181, 3240182), (3241795, 3241796), (3241849, 3241850), (3241855, 3241856), (3241861, 3241862), (3242115, 3242116), (3242186, 3242187), (3242431, 3242432), (3242455, 3242456)]
kernel_rfl DEC_clearFill.st1.fh120 : DEC_clearFill.st1.s121.heap = setAll DEC_clearFill.st1.s120.heap (rangesOf DEC_clearFill.st1.s121.heap DEC_clearFill.st1.fR120 ++ freshOf DEC_clearFill.st1.s121.heap DEC_clearFill.st1.s120.next DEC_clearFill.st1.s121.next)
kernel_rfl DEC_clearFill.st1.fb120 : footRB DEC_clearFill.st1.s120 DEC_clearFill.st1.s121 DEC_clearFill.st1.fR120 = true
kernel_rfl DEC_clearFill.st1.fc120 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s120.next && Nat.ble DEC_clearFill.st1.s121.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR120 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa121 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s121 :=
  DEC_clearFill.st1.fa120.step (stageFoot_ofRF DEC_clearFill.st1.fh120 DEC_clearFill.st1.fb120) (incl_of_footW DEC_clearFill.st1.fb120 DEC_clearFill.st1.fc120)

def DEC_clearFill.st1.fR121 : List (Nat × Nat) := [(2672694, 2672695), (3095648, 3095649), (3095700, 3095701), (3242546, 3242549), (3242612, 3242619), (3242935, 3242936), (3243345, 3243346), (3243380, 3243381), (3243415, 3243416), (3243440, 3243442), (3243453, 3243455), (3243517, 3243518), (3243528, 3243529)]
kernel_rfl DEC_clearFill.st1.fh121 : DEC_clearFill.st1.s122.heap = setAll DEC_clearFill.st1.s121.heap (rangesOf DEC_clearFill.st1.s122.heap DEC_clearFill.st1.fR121 ++ freshOf DEC_clearFill.st1.s122.heap DEC_clearFill.st1.s121.next DEC_clearFill.st1.s122.next)
kernel_rfl DEC_clearFill.st1.fb121 : footRB DEC_clearFill.st1.s121 DEC_clearFill.st1.s122 DEC_clearFill.st1.fR121 = true
kernel_rfl DEC_clearFill.st1.fc121 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s121.next && Nat.ble DEC_clearFill.st1.s122.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR121 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa122 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s122 :=
  DEC_clearFill.st1.fa121.step (stageFoot_ofRF DEC_clearFill.st1.fh121 DEC_clearFill.st1.fb121) (incl_of_footW DEC_clearFill.st1.fb121 DEC_clearFill.st1.fc121)

def DEC_clearFill.st1.fR122 : List (Nat × Nat) := [(3123796, 3123797), (3242507, 3242508), (3242574, 3242575), (3243967, 3243968), (3244025, 3244026), (3244031, 3244032), (3244037, 3244038), (3244291, 3244292), (3244312, 3244313), (3244362, 3244363), (3244380, 3244382), (3244414, 3244415), (3244417, 3244427), (3244499, 3244500)]
kernel_rfl DEC_clearFill.st1.fh122 : DEC_clearFill.st1.s123.heap = setAll DEC_clearFill.st1.s122.heap (rangesOf DEC_clearFill.st1.s123.heap DEC_clearFill.st1.fR122 ++ freshOf DEC_clearFill.st1.s123.heap DEC_clearFill.st1.s122.next DEC_clearFill.st1.s123.next)
kernel_rfl DEC_clearFill.st1.fb122 : footRB DEC_clearFill.st1.s122 DEC_clearFill.st1.s123 DEC_clearFill.st1.fR122 = true
kernel_rfl DEC_clearFill.st1.fc122 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s122.next && Nat.ble DEC_clearFill.st1.s123.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR122 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa123 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s123 :=
  DEC_clearFill.st1.fa122.step (stageFoot_ofRF DEC_clearFill.st1.fh122 DEC_clearFill.st1.fb122) (incl_of_footW DEC_clearFill.st1.fb122 DEC_clearFill.st1.fc122)

def DEC_clearFill.st1.fR123 : List (Nat × Nat) := [(2672703, 2672704), (3097754, 3097755), (3098183, 3098184), (3244743, 3244746), (3244791, 3244796), (3244985, 3244986), (3245210, 3245211), (3245296, 3245297), (3245385, 3245386), (3245423, 3245430), (3245468, 3245471), (3245523, 3245524)]
kernel_rfl DEC_clearFill.st1.fh123 : DEC_clearFill.st1.s124.heap = setAll DEC_clearFill.st1.s123.heap (rangesOf DEC_clearFill.st1.s124.heap DEC_clearFill.st1.fR123 ++ freshOf DEC_clearFill.st1.s124.heap DEC_clearFill.st1.s123.next DEC_clearFill.st1.s124.next)
kernel_rfl DEC_clearFill.st1.fb123 : footRB DEC_clearFill.st1.s123 DEC_clearFill.st1.s124 DEC_clearFill.st1.fR123 = true
kernel_rfl DEC_clearFill.st1.fc123 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s123.next && Nat.ble DEC_clearFill.st1.s124.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR123 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa124 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s124 :=
  DEC_clearFill.st1.fa123.step (stageFoot_ofRF DEC_clearFill.st1.fh123 DEC_clearFill.st1.fb123) (incl_of_footW DEC_clearFill.st1.fb123 DEC_clearFill.st1.fc123)

def DEC_clearFill.st1.fR124 : List (Nat × Nat) := [(3123796, 3123797), (3244683, 3244684), (3244771, 3244772), (3246385, 3246386), (3246439, 3246440), (3246445, 3246446), (3246451, 3246452), (3246459, 3246460), (3246470, 3246474)]
kernel_rfl DEC_clearFill.st1.fh124 : DEC_clearFill.st1.s125.heap = setAll DEC_clearFill.st1.s124.heap (rangesOf DEC_clearFill.st1.s125.heap DEC_clearFill.st1.fR124 ++ freshOf DEC_clearFill.st1.s125.heap DEC_clearFill.st1.s124.next DEC_clearFill.st1.s125.next)
kernel_rfl DEC_clearFill.st1.fb124 : footRB DEC_clearFill.st1.s124 DEC_clearFill.st1.s125 DEC_clearFill.st1.fR124 = true
kernel_rfl DEC_clearFill.st1.fc124 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s124.next && Nat.ble DEC_clearFill.st1.s125.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR124 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa125 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s125 :=
  DEC_clearFill.st1.fa124.step (stageFoot_ofRF DEC_clearFill.st1.fh124 DEC_clearFill.st1.fb124) (incl_of_footW DEC_clearFill.st1.fb124 DEC_clearFill.st1.fc124)

def DEC_clearFill.st1.fR125 : List (Nat × Nat) := [(2672708, 2672709), (3100046, 3100047), (3100475, 3100476), (3247179, 3247185), (3247377, 3247378), (3247393, 3247394), (3247445, 3247447), (3247448, 3247449)]
kernel_rfl DEC_clearFill.st1.fh125 : DEC_clearFill.st1.s126.heap = setAll DEC_clearFill.st1.s125.heap (rangesOf DEC_clearFill.st1.s126.heap DEC_clearFill.st1.fR125 ++ freshOf DEC_clearFill.st1.s126.heap DEC_clearFill.st1.s125.next DEC_clearFill.st1.s126.next)
kernel_rfl DEC_clearFill.st1.fb125 : footRB DEC_clearFill.st1.s125 DEC_clearFill.st1.s126 DEC_clearFill.st1.fR125 = true
kernel_rfl DEC_clearFill.st1.fc125 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s125.next && Nat.ble DEC_clearFill.st1.s126.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR125 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa126 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s126 :=
  DEC_clearFill.st1.fa125.step (stageFoot_ofRF DEC_clearFill.st1.fh125 DEC_clearFill.st1.fb125) (incl_of_footW DEC_clearFill.st1.fb125 DEC_clearFill.st1.fc125)

def DEC_clearFill.st1.fR126 : List (Nat × Nat) := [(3247135, 3247138), (3247185, 3247188), (3247502, 3247503), (3248375, 3248376), (3248461, 3248462)]
kernel_rfl DEC_clearFill.st1.fh126 : DEC_clearFill.st1.s127.heap = setAll DEC_clearFill.st1.s126.heap (rangesOf DEC_clearFill.st1.s127.heap DEC_clearFill.st1.fR126 ++ freshOf DEC_clearFill.st1.s127.heap DEC_clearFill.st1.s126.next DEC_clearFill.st1.s127.next)
kernel_rfl DEC_clearFill.st1.fb126 : footRB DEC_clearFill.st1.s126 DEC_clearFill.st1.s127 DEC_clearFill.st1.fR126 = true
kernel_rfl DEC_clearFill.st1.fc126 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s126.next && Nat.ble DEC_clearFill.st1.s127.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR126 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa127 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s127 :=
  DEC_clearFill.st1.fa126.step (stageFoot_ofRF DEC_clearFill.st1.fh126 DEC_clearFill.st1.fb126) (incl_of_footW DEC_clearFill.st1.fb126 DEC_clearFill.st1.fc126)

def DEC_clearFill.st1.fR127 : List (Nat × Nat) := [(2672713, 2672714), (3102238, 3102239), (3123796, 3123797), (3247097, 3247098), (3247163, 3247164), (3248677, 3248678)]
kernel_rfl DEC_clearFill.st1.fh127 : DEC_clearFill.st1.s128.heap = setAll DEC_clearFill.st1.s127.heap (rangesOf DEC_clearFill.st1.s128.heap DEC_clearFill.st1.fR127 ++ freshOf DEC_clearFill.st1.s128.heap DEC_clearFill.st1.s127.next DEC_clearFill.st1.s128.next)
kernel_rfl DEC_clearFill.st1.fb127 : footRB DEC_clearFill.st1.s127 DEC_clearFill.st1.s128 DEC_clearFill.st1.fR127 = true
kernel_rfl DEC_clearFill.st1.fc127 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s127.next && Nat.ble DEC_clearFill.st1.s128.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR127 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa128 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s128 :=
  DEC_clearFill.st1.fa127.step (stageFoot_ofRF DEC_clearFill.st1.fh127 DEC_clearFill.st1.fb127) (incl_of_footW DEC_clearFill.st1.fb127 DEC_clearFill.st1.fc127)

end Host.Load.Run.Tpl

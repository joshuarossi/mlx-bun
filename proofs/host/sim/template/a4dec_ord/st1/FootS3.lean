import host.sim.template.a4dec_ord.st1.FootS2
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_ord.st1.fR96 : List (Nat × Nat) := [(3123795, 3123796), (3216540, 3216541), (3216628, 3216629), (3218242, 3218243), (3218296, 3218297), (3218302, 3218303), (3218308, 3218309), (3218562, 3218563), (3218583, 3218584), (3218633, 3218634), (3218651, 3218653), (3218685, 3218686), (3218688, 3218698), (3218770, 3218771)]
kernel_rfl DEC_ord.st1.fh96 : DEC_ord.st1.s97.heap = setAll DEC_ord.st1.s96.heap (rangesOf DEC_ord.st1.s97.heap DEC_ord.st1.fR96 ++ freshOf DEC_ord.st1.s97.heap DEC_ord.st1.s96.next DEC_ord.st1.s97.next)
kernel_rfl DEC_ord.st1.fb96 : footRB DEC_ord.st1.s96 DEC_ord.st1.s97 DEC_ord.st1.fR96 = true
kernel_rfl DEC_ord.st1.fc96 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s96.next && Nat.ble DEC_ord.st1.s97.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR96 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa97 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s97 :=
  DEC_ord.st1.fa96.step (stageFoot_ofRF DEC_ord.st1.fh96 DEC_ord.st1.fb96) (incl_of_footW DEC_ord.st1.fb96 DEC_ord.st1.fc96)

def DEC_ord.st1.fR97 : List (Nat × Nat) := [(2672615, 2672616), (3072004, 3072005), (3072433, 3072434), (3218992, 3218995), (3219040, 3219045), (3219234, 3219235), (3219459, 3219460), (3219545, 3219546), (3219634, 3219635), (3219672, 3219679), (3219718, 3219720), (3219772, 3219773)]
kernel_rfl DEC_ord.st1.fh97 : DEC_ord.st1.s98.heap = setAll DEC_ord.st1.s97.heap (rangesOf DEC_ord.st1.s98.heap DEC_ord.st1.fR97 ++ freshOf DEC_ord.st1.s98.heap DEC_ord.st1.s97.next DEC_ord.st1.s98.next)
kernel_rfl DEC_ord.st1.fb97 : footRB DEC_ord.st1.s97 DEC_ord.st1.s98 DEC_ord.st1.fR97 = true
kernel_rfl DEC_ord.st1.fc97 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s97.next && Nat.ble DEC_ord.st1.s98.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR97 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa98 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s98 :=
  DEC_ord.st1.fa97.step (stageFoot_ofRF DEC_ord.st1.fh97 DEC_ord.st1.fb97) (incl_of_footW DEC_ord.st1.fb97 DEC_ord.st1.fc97)

def DEC_ord.st1.fR98 : List (Nat × Nat) := [(3123795, 3123796), (3218954, 3218955), (3219020, 3219021), (3220634, 3220635), (3220688, 3220689), (3220694, 3220695), (3220700, 3220701), (3220708, 3220709), (3220719, 3220723)]
kernel_rfl DEC_ord.st1.fh98 : DEC_ord.st1.s99.heap = setAll DEC_ord.st1.s98.heap (rangesOf DEC_ord.st1.s99.heap DEC_ord.st1.fR98 ++ freshOf DEC_ord.st1.s99.heap DEC_ord.st1.s98.next DEC_ord.st1.s99.next)
kernel_rfl DEC_ord.st1.fb98 : footRB DEC_ord.st1.s98 DEC_ord.st1.s99 DEC_ord.st1.fR98 = true
kernel_rfl DEC_ord.st1.fc98 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s98.next && Nat.ble DEC_ord.st1.s99.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR98 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa99 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s99 :=
  DEC_ord.st1.fa98.step (stageFoot_ofRF DEC_ord.st1.fh98 DEC_ord.st1.fb98) (incl_of_footW DEC_ord.st1.fb98 DEC_ord.st1.fc98)

def DEC_ord.st1.fR99 : List (Nat × Nat) := [(2672620, 2672621), (3074396, 3074397), (3221428, 3221432), (3221657, 3221658), (3221725, 3221726), (3221727, 3221738)]
kernel_rfl DEC_ord.st1.fh99 : DEC_ord.st1.s100.heap = setAll DEC_ord.st1.s99.heap (rangesOf DEC_ord.st1.s100.heap DEC_ord.st1.fR99 ++ freshOf DEC_ord.st1.s100.heap DEC_ord.st1.s99.next DEC_ord.st1.s100.next)
kernel_rfl DEC_ord.st1.fb99 : footRB DEC_ord.st1.s99 DEC_ord.st1.s100 DEC_ord.st1.fR99 = true
kernel_rfl DEC_ord.st1.fc99 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s99.next && Nat.ble DEC_ord.st1.s100.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR99 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa100 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s100 :=
  DEC_ord.st1.fa99.step (stageFoot_ofRF DEC_ord.st1.fh99 DEC_ord.st1.fb99) (incl_of_footW DEC_ord.st1.fb99 DEC_ord.st1.fc99)

def DEC_ord.st1.fR100 : List (Nat × Nat) := [(2672620, 2672621), (3074825, 3074826), (3221384, 3221387), (3221432, 3221437), (3221626, 3221627), (3221851, 3221852), (3221937, 3221938), (3222026, 3222027), (3222069, 3222071), (3222392, 3222393), (3222398, 3222399), (3222404, 3222405), (3222724, 3222725)]
kernel_rfl DEC_ord.st1.fh100 : DEC_ord.st1.s101.heap = setAll DEC_ord.st1.s100.heap (rangesOf DEC_ord.st1.s101.heap DEC_ord.st1.fR100 ++ freshOf DEC_ord.st1.s101.heap DEC_ord.st1.s100.next DEC_ord.st1.s101.next)
kernel_rfl DEC_ord.st1.fb100 : footRB DEC_ord.st1.s100 DEC_ord.st1.s101 DEC_ord.st1.fR100 = true
kernel_rfl DEC_ord.st1.fc100 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s100.next && Nat.ble DEC_ord.st1.s101.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR100 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa101 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s101 :=
  DEC_ord.st1.fa100.step (stageFoot_ofRF DEC_ord.st1.fh100 DEC_ord.st1.fb100) (incl_of_footW DEC_ord.st1.fb100 DEC_ord.st1.fc100)

def DEC_ord.st1.fR101 : List (Nat × Nat) := [(4841, 4842), (2672632, 2672633), (3123795, 3123796), (3221346, 3221347), (3221412, 3221413), (3223026, 3223027), (3223080, 3223081), (3223086, 3223087), (3223092, 3223093), (3223346, 3223347), (3223367, 3223368), (3223417, 3223418), (3223436, 3223437), (3223579, 3223580), (3223657, 3223658), (3223662, 3223663)]
kernel_rfl DEC_ord.st1.fh101 : DEC_ord.st1.s102.heap = setAll DEC_ord.st1.s101.heap (rangesOf DEC_ord.st1.s102.heap DEC_ord.st1.fR101 ++ freshOf DEC_ord.st1.s102.heap DEC_ord.st1.s101.next DEC_ord.st1.s102.next)
kernel_rfl DEC_ord.st1.fb101 : footRB DEC_ord.st1.s101 DEC_ord.st1.s102 DEC_ord.st1.fR101 = true
kernel_rfl DEC_ord.st1.fc101 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s101.next && Nat.ble DEC_ord.st1.s102.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR101 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa102 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s102 :=
  DEC_ord.st1.fa101.step (stageFoot_ofRF DEC_ord.st1.fh101 DEC_ord.st1.fb101) (incl_of_footW DEC_ord.st1.fb101 DEC_ord.st1.fc101)

def DEC_ord.st1.fR102 : List (Nat × Nat) := [(2672632, 2672633), (3076880, 3076881), (3076932, 3076933), (3223777, 3223780), (3223843, 3223850), (3224166, 3224167), (3224576, 3224577), (3224611, 3224612), (3224646, 3224647), (3224671, 3224673), (3224683, 3224686), (3224727, 3224729)]
kernel_rfl DEC_ord.st1.fh102 : DEC_ord.st1.s103.heap = setAll DEC_ord.st1.s102.heap (rangesOf DEC_ord.st1.s103.heap DEC_ord.st1.fR102 ++ freshOf DEC_ord.st1.s103.heap DEC_ord.st1.s102.next DEC_ord.st1.s103.next)
kernel_rfl DEC_ord.st1.fb102 : footRB DEC_ord.st1.s102 DEC_ord.st1.s103 DEC_ord.st1.fR102 = true
kernel_rfl DEC_ord.st1.fc102 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s102.next && Nat.ble DEC_ord.st1.s103.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR102 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa103 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s103 :=
  DEC_ord.st1.fa102.step (stageFoot_ofRF DEC_ord.st1.fh102 DEC_ord.st1.fb102) (incl_of_footW DEC_ord.st1.fb102 DEC_ord.st1.fc102)

def DEC_ord.st1.fR103 : List (Nat × Nat) := [(3123795, 3123796), (3223738, 3223739), (3223805, 3223806), (3225198, 3225199), (3225256, 3225257), (3225262, 3225263), (3225268, 3225269), (3225522, 3225523), (3225543, 3225544), (3225593, 3225594), (3225611, 3225613), (3225645, 3225646), (3225648, 3225658)]
kernel_rfl DEC_ord.st1.fh103 : DEC_ord.st1.s104.heap = setAll DEC_ord.st1.s103.heap (rangesOf DEC_ord.st1.s104.heap DEC_ord.st1.fR103 ++ freshOf DEC_ord.st1.s104.heap DEC_ord.st1.s103.next DEC_ord.st1.s104.next)
kernel_rfl DEC_ord.st1.fb103 : footRB DEC_ord.st1.s103 DEC_ord.st1.s104 DEC_ord.st1.fR103 = true
kernel_rfl DEC_ord.st1.fc103 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s103.next && Nat.ble DEC_ord.st1.s104.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR103 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa104 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s104 :=
  DEC_ord.st1.fa103.step (stageFoot_ofRF DEC_ord.st1.fh103 DEC_ord.st1.fb103) (incl_of_footW DEC_ord.st1.fb103 DEC_ord.st1.fc103)

def DEC_ord.st1.fR104 : List (Nat × Nat) := [(2672641, 2672642), (3078986, 3078987), (3079415, 3079416), (3225974, 3225975), (3226022, 3226027), (3226216, 3226217), (3226441, 3226442), (3226527, 3226528), (3226616, 3226617), (3226654, 3226661), (3226699, 3226702), (3226720, 3226722), (3226728, 3226729)]
kernel_rfl DEC_ord.st1.fh104 : DEC_ord.st1.s105.heap = setAll DEC_ord.st1.s104.heap (rangesOf DEC_ord.st1.s105.heap DEC_ord.st1.fR104 ++ freshOf DEC_ord.st1.s105.heap DEC_ord.st1.s104.next DEC_ord.st1.s105.next)
kernel_rfl DEC_ord.st1.fb104 : footRB DEC_ord.st1.s104 DEC_ord.st1.s105 DEC_ord.st1.fR104 = true
kernel_rfl DEC_ord.st1.fc104 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s104.next && Nat.ble DEC_ord.st1.s105.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR104 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa105 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s105 :=
  DEC_ord.st1.fa104.step (stageFoot_ofRF DEC_ord.st1.fh104 DEC_ord.st1.fb104) (incl_of_footW DEC_ord.st1.fb104 DEC_ord.st1.fc104)

def DEC_ord.st1.fR105 : List (Nat × Nat) := [(3123795, 3123796), (3225914, 3225915), (3225975, 3225977), (3226002, 3226003), (3227616, 3227617), (3227665, 3227667), (3227670, 3227671)]
kernel_rfl DEC_ord.st1.fh105 : DEC_ord.st1.s106.heap = setAll DEC_ord.st1.s105.heap (rangesOf DEC_ord.st1.s106.heap DEC_ord.st1.fR105 ++ freshOf DEC_ord.st1.s106.heap DEC_ord.st1.s105.next DEC_ord.st1.s106.next)
kernel_rfl DEC_ord.st1.fb105 : footRB DEC_ord.st1.s105 DEC_ord.st1.s106 DEC_ord.st1.fR105 = true
kernel_rfl DEC_ord.st1.fc105 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s105.next && Nat.ble DEC_ord.st1.s106.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR105 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa106 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s106 :=
  DEC_ord.st1.fa105.step (stageFoot_ofRF DEC_ord.st1.fh105 DEC_ord.st1.fb105) (incl_of_footW DEC_ord.st1.fb105 DEC_ord.st1.fc105)

def DEC_ord.st1.fR106 : List (Nat × Nat) := [(2672646, 2672647), (3081378, 3081379), (3228410, 3228414), (3228638, 3228640), (3228659, 3228661)]
kernel_rfl DEC_ord.st1.fh106 : DEC_ord.st1.s107.heap = setAll DEC_ord.st1.s106.heap (rangesOf DEC_ord.st1.s107.heap DEC_ord.st1.fR106 ++ freshOf DEC_ord.st1.s107.heap DEC_ord.st1.s106.next DEC_ord.st1.s107.next)
kernel_rfl DEC_ord.st1.fb106 : footRB DEC_ord.st1.s106 DEC_ord.st1.s107 DEC_ord.st1.fR106 = true
kernel_rfl DEC_ord.st1.fc106 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s106.next && Nat.ble DEC_ord.st1.s107.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR106 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa107 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s107 :=
  DEC_ord.st1.fa106.step (stageFoot_ofRF DEC_ord.st1.fh106 DEC_ord.st1.fb106) (incl_of_footW DEC_ord.st1.fb106 DEC_ord.st1.fc106)

def DEC_ord.st1.fR107 : List (Nat × Nat) := [(2672646, 2672647), (3081807, 3081808), (3228366, 3228369), (3228414, 3228419), (3228608, 3228609), (3228833, 3228834), (3228919, 3228920), (3229008, 3229009), (3229051, 3229053), (3229374, 3229375), (3229380, 3229381), (3229386, 3229387), (3229415, 3229417), (3229461, 3229462), (3229505, 3229506), (3229527, 3229529), (3229568, 3229569), (3229610, 3229613)]
kernel_rfl DEC_ord.st1.fh107 : DEC_ord.st1.s108.heap = setAll DEC_ord.st1.s107.heap (rangesOf DEC_ord.st1.s108.heap DEC_ord.st1.fR107 ++ freshOf DEC_ord.st1.s108.heap DEC_ord.st1.s107.next DEC_ord.st1.s108.next)
kernel_rfl DEC_ord.st1.fb107 : footRB DEC_ord.st1.s107 DEC_ord.st1.s108 DEC_ord.st1.fR107 = true
kernel_rfl DEC_ord.st1.fc107 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s107.next && Nat.ble DEC_ord.st1.s108.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR107 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa108 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s108 :=
  DEC_ord.st1.fa107.step (stageFoot_ofRF DEC_ord.st1.fh107 DEC_ord.st1.fb107) (incl_of_footW DEC_ord.st1.fb107 DEC_ord.st1.fc107)

def DEC_ord.st1.fR108 : List (Nat × Nat) := [(3123795, 3123796), (3228328, 3228329), (3228394, 3228395), (3230008, 3230009), (3230062, 3230063), (3230068, 3230069), (3230074, 3230075), (3230328, 3230329), (3230349, 3230350), (3230399, 3230400), (3230422, 3230423), (3230565, 3230566), (3230594, 3230595), (3230597, 3230607)]
kernel_rfl DEC_ord.st1.fh108 : DEC_ord.st1.s109.heap = setAll DEC_ord.st1.s108.heap (rangesOf DEC_ord.st1.s109.heap DEC_ord.st1.fR108 ++ freshOf DEC_ord.st1.s109.heap DEC_ord.st1.s108.next DEC_ord.st1.s109.next)
kernel_rfl DEC_ord.st1.fb108 : footRB DEC_ord.st1.s108 DEC_ord.st1.s109 DEC_ord.st1.fR108 = true
kernel_rfl DEC_ord.st1.fc108 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s108.next && Nat.ble DEC_ord.st1.s109.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR108 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa109 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s109 :=
  DEC_ord.st1.fa108.step (stageFoot_ofRF DEC_ord.st1.fh108 DEC_ord.st1.fb108) (incl_of_footW DEC_ord.st1.fb108 DEC_ord.st1.fc108)

def DEC_ord.st1.fR109 : List (Nat × Nat) := [(2672651, 2672652), (3083774, 3083775), (3084203, 3084204), (3230762, 3230765), (3230810, 3230815), (3231004, 3231005), (3231229, 3231230), (3231315, 3231316), (3231404, 3231405), (3231442, 3231449), (3231488, 3231490), (3231542, 3231543), (3231624, 3231625), (3231669, 3231671), (3231672, 3231673)]
kernel_rfl DEC_ord.st1.fh109 : DEC_ord.st1.s110.heap = setAll DEC_ord.st1.s109.heap (rangesOf DEC_ord.st1.s110.heap DEC_ord.st1.fR109 ++ freshOf DEC_ord.st1.s110.heap DEC_ord.st1.s109.next DEC_ord.st1.s110.next)
kernel_rfl DEC_ord.st1.fb109 : footRB DEC_ord.st1.s109 DEC_ord.st1.s110 DEC_ord.st1.fR109 = true
kernel_rfl DEC_ord.st1.fc109 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s109.next && Nat.ble DEC_ord.st1.s110.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR109 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa110 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s110 :=
  DEC_ord.st1.fa109.step (stageFoot_ofRF DEC_ord.st1.fh109 DEC_ord.st1.fb109) (incl_of_footW DEC_ord.st1.fb109 DEC_ord.st1.fc109)

def DEC_ord.st1.fR110 : List (Nat × Nat) := [(3123795, 3123796), (3230724, 3230725), (3230790, 3230791), (3232404, 3232405), (3232458, 3232459), (3232464, 3232465), (3232470, 3232471), (3232478, 3232479), (3232491, 3232493), (3232547, 3232548), (3232575, 3232576), (3232578, 3232588)]
kernel_rfl DEC_ord.st1.fh110 : DEC_ord.st1.s111.heap = setAll DEC_ord.st1.s110.heap (rangesOf DEC_ord.st1.s111.heap DEC_ord.st1.fR110 ++ freshOf DEC_ord.st1.s111.heap DEC_ord.st1.s110.next DEC_ord.st1.s111.next)
kernel_rfl DEC_ord.st1.fb110 : footRB DEC_ord.st1.s110 DEC_ord.st1.s111 DEC_ord.st1.fR110 = true
kernel_rfl DEC_ord.st1.fc110 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s110.next && Nat.ble DEC_ord.st1.s111.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR110 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa111 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s111 :=
  DEC_ord.st1.fa110.step (stageFoot_ofRF DEC_ord.st1.fh110 DEC_ord.st1.fb110) (incl_of_footW DEC_ord.st1.fb110 DEC_ord.st1.fc110)

def DEC_ord.st1.fR111 : List (Nat × Nat) := [(4841, 4842), (2672663, 2672664), (3086262, 3086263), (3086314, 3086315), (3233159, 3233160), (3233222, 3233232), (3233453, 3233454), (3233548, 3233549), (3233561, 3233562), (3233579, 3233580)]
kernel_rfl DEC_ord.st1.fh111 : DEC_ord.st1.s112.heap = setAll DEC_ord.st1.s111.heap (rangesOf DEC_ord.st1.s112.heap DEC_ord.st1.fR111 ++ freshOf DEC_ord.st1.s112.heap DEC_ord.st1.s111.next DEC_ord.st1.s112.next)
kernel_rfl DEC_ord.st1.fb111 : footRB DEC_ord.st1.s111 DEC_ord.st1.s112 DEC_ord.st1.fR111 = true
kernel_rfl DEC_ord.st1.fc111 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s111.next && Nat.ble DEC_ord.st1.s112.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR111 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa112 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s112 :=
  DEC_ord.st1.fa111.step (stageFoot_ofRF DEC_ord.st1.fh111 DEC_ord.st1.fb111) (incl_of_footW DEC_ord.st1.fb111 DEC_ord.st1.fc111)

def DEC_ord.st1.fR112 : List (Nat × Nat) := [(3123795, 3123796), (3233120, 3233121), (3233160, 3233162), (3233187, 3233188), (3234580, 3234581), (3234608, 3234617)]
kernel_rfl DEC_ord.st1.fh112 : DEC_ord.st1.s113.heap = setAll DEC_ord.st1.s112.heap (rangesOf DEC_ord.st1.s113.heap DEC_ord.st1.fR112 ++ freshOf DEC_ord.st1.s113.heap DEC_ord.st1.s112.next DEC_ord.st1.s113.next)
kernel_rfl DEC_ord.st1.fb112 : footRB DEC_ord.st1.s112 DEC_ord.st1.s113 DEC_ord.st1.fR112 = true
kernel_rfl DEC_ord.st1.fc112 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s112.next && Nat.ble DEC_ord.st1.s113.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR112 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa113 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s113 :=
  DEC_ord.st1.fa112.step (stageFoot_ofRF DEC_ord.st1.fh112 DEC_ord.st1.fb112) (incl_of_footW DEC_ord.st1.fb112 DEC_ord.st1.fc112)

def DEC_ord.st1.fR113 : List (Nat × Nat) := [(2672672, 2672673), (3088372, 3088373), (3235403, 3235408), (3235444, 3235445), (3235521, 3235525)]
kernel_rfl DEC_ord.st1.fh113 : DEC_ord.st1.s114.heap = setAll DEC_ord.st1.s113.heap (rangesOf DEC_ord.st1.s114.heap DEC_ord.st1.fR113 ++ freshOf DEC_ord.st1.s114.heap DEC_ord.st1.s113.next DEC_ord.st1.s114.next)
kernel_rfl DEC_ord.st1.fb113 : footRB DEC_ord.st1.s113 DEC_ord.st1.s114 DEC_ord.st1.fR113 = true
kernel_rfl DEC_ord.st1.fc113 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s113.next && Nat.ble DEC_ord.st1.s114.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR113 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa114 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s114 :=
  DEC_ord.st1.fa113.step (stageFoot_ofRF DEC_ord.st1.fh113 DEC_ord.st1.fb113) (incl_of_footW DEC_ord.st1.fb113 DEC_ord.st1.fc113)

def DEC_ord.st1.fR114 : List (Nat × Nat) := [(2672672, 2672673), (3088801, 3088802), (3235360, 3235363), (3235408, 3235413), (3235602, 3235603), (3235827, 3235828), (3235913, 3235914), (3236002, 3236003), (3236045, 3236047), (3236368, 3236369), (3236374, 3236375), (3236380, 3236381), (3236409, 3236411), (3236455, 3236456), (3236499, 3236500), (3236521, 3236523), (3236562, 3236563), (3236594, 3236595), (3236597, 3236607), (3236659, 3236660)]
kernel_rfl DEC_ord.st1.fh114 : DEC_ord.st1.s115.heap = setAll DEC_ord.st1.s114.heap (rangesOf DEC_ord.st1.s115.heap DEC_ord.st1.fR114 ++ freshOf DEC_ord.st1.s115.heap DEC_ord.st1.s114.next DEC_ord.st1.s115.next)
kernel_rfl DEC_ord.st1.fb114 : footRB DEC_ord.st1.s114 DEC_ord.st1.s115 DEC_ord.st1.fR114 = true
kernel_rfl DEC_ord.st1.fc114 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s114.next && Nat.ble DEC_ord.st1.s115.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR114 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa115 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s115 :=
  DEC_ord.st1.fa114.step (stageFoot_ofRF DEC_ord.st1.fh114 DEC_ord.st1.fb114) (incl_of_footW DEC_ord.st1.fb114 DEC_ord.st1.fc114)

def DEC_ord.st1.fR115 : List (Nat × Nat) := [(3123795, 3123796), (3235300, 3235301), (3235388, 3235389), (3237002, 3237003), (3237056, 3237057), (3237062, 3237063), (3237068, 3237069), (3237322, 3237323), (3237343, 3237344), (3237393, 3237394), (3237415, 3237417), (3237461, 3237462), (3237554, 3237556)]
kernel_rfl DEC_ord.st1.fh115 : DEC_ord.st1.s116.heap = setAll DEC_ord.st1.s115.heap (rangesOf DEC_ord.st1.s116.heap DEC_ord.st1.fR115 ++ freshOf DEC_ord.st1.s116.heap DEC_ord.st1.s115.next DEC_ord.st1.s116.next)
kernel_rfl DEC_ord.st1.fb115 : footRB DEC_ord.st1.s115 DEC_ord.st1.s116 DEC_ord.st1.fR115 = true
kernel_rfl DEC_ord.st1.fc115 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s115.next && Nat.ble DEC_ord.st1.s116.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR115 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa116 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s116 :=
  DEC_ord.st1.fa115.step (stageFoot_ofRF DEC_ord.st1.fh115 DEC_ord.st1.fb115) (incl_of_footW DEC_ord.st1.fb115 DEC_ord.st1.fc115)

def DEC_ord.st1.fR116 : List (Nat × Nat) := [(2672677, 2672678), (3090768, 3090769), (3091197, 3091198), (3237756, 3237759), (3237804, 3237809), (3237998, 3237999), (3238223, 3238224), (3238309, 3238310), (3238398, 3238399), (3238436, 3238443), (3238482, 3238484), (3238536, 3238537), (3238561, 3238562), (3238584, 3238585), (3238595, 3238596)]
kernel_rfl DEC_ord.st1.fh116 : DEC_ord.st1.s117.heap = setAll DEC_ord.st1.s116.heap (rangesOf DEC_ord.st1.s117.heap DEC_ord.st1.fR116 ++ freshOf DEC_ord.st1.s117.heap DEC_ord.st1.s116.next DEC_ord.st1.s117.next)
kernel_rfl DEC_ord.st1.fb116 : footRB DEC_ord.st1.s116 DEC_ord.st1.s117 DEC_ord.st1.fR116 = true
kernel_rfl DEC_ord.st1.fc116 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s116.next && Nat.ble DEC_ord.st1.s117.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR116 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa117 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s117 :=
  DEC_ord.st1.fa116.step (stageFoot_ofRF DEC_ord.st1.fh116 DEC_ord.st1.fb116) (incl_of_footW DEC_ord.st1.fb116 DEC_ord.st1.fc116)

def DEC_ord.st1.fR117 : List (Nat × Nat) := [(3123795, 3123796), (3237718, 3237719), (3237784, 3237785), (3239398, 3239399), (3239452, 3239453), (3239458, 3239459), (3239464, 3239465), (3239472, 3239473), (3239484, 3239487), (3239534, 3239535)]
kernel_rfl DEC_ord.st1.fh117 : DEC_ord.st1.s118.heap = setAll DEC_ord.st1.s117.heap (rangesOf DEC_ord.st1.s118.heap DEC_ord.st1.fR117 ++ freshOf DEC_ord.st1.s118.heap DEC_ord.st1.s117.next DEC_ord.st1.s118.next)
kernel_rfl DEC_ord.st1.fb117 : footRB DEC_ord.st1.s117 DEC_ord.st1.s118 DEC_ord.st1.fR117 = true
kernel_rfl DEC_ord.st1.fc117 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s117.next && Nat.ble DEC_ord.st1.s118.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR117 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa118 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s118 :=
  DEC_ord.st1.fa117.step (stageFoot_ofRF DEC_ord.st1.fh117 DEC_ord.st1.fb117) (incl_of_footW DEC_ord.st1.fb117 DEC_ord.st1.fc117)

def DEC_ord.st1.fR118 : List (Nat × Nat) := [(2672682, 2672683), (3093164, 3093165), (3240196, 3240200), (3240394, 3240395), (3240425, 3240426), (3240493, 3240494), (3240496, 3240506)]
kernel_rfl DEC_ord.st1.fh118 : DEC_ord.st1.s119.heap = setAll DEC_ord.st1.s118.heap (rangesOf DEC_ord.st1.s119.heap DEC_ord.st1.fR118 ++ freshOf DEC_ord.st1.s119.heap DEC_ord.st1.s118.next DEC_ord.st1.s119.next)
kernel_rfl DEC_ord.st1.fb118 : footRB DEC_ord.st1.s118 DEC_ord.st1.s119 DEC_ord.st1.fR118 = true
kernel_rfl DEC_ord.st1.fc118 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s118.next && Nat.ble DEC_ord.st1.s119.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR118 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa119 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s119 :=
  DEC_ord.st1.fa118.step (stageFoot_ofRF DEC_ord.st1.fh118 DEC_ord.st1.fb118) (incl_of_footW DEC_ord.st1.fb118 DEC_ord.st1.fc118)

def DEC_ord.st1.fR119 : List (Nat × Nat) := [(2672682, 2672683), (3093593, 3093594), (3240152, 3240155), (3240200, 3240205), (3240619, 3240620), (3240705, 3240706), (3241492, 3241493)]
kernel_rfl DEC_ord.st1.fh119 : DEC_ord.st1.s120.heap = setAll DEC_ord.st1.s119.heap (rangesOf DEC_ord.st1.s120.heap DEC_ord.st1.fR119 ++ freshOf DEC_ord.st1.s120.heap DEC_ord.st1.s119.next DEC_ord.st1.s120.next)
kernel_rfl DEC_ord.st1.fb119 : footRB DEC_ord.st1.s119 DEC_ord.st1.s120 DEC_ord.st1.fR119 = true
kernel_rfl DEC_ord.st1.fc119 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s119.next && Nat.ble DEC_ord.st1.s120.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR119 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa120 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s120 :=
  DEC_ord.st1.fa119.step (stageFoot_ofRF DEC_ord.st1.fh119 DEC_ord.st1.fb119) (incl_of_footW DEC_ord.st1.fb119 DEC_ord.st1.fc119)

def DEC_ord.st1.fR120 : List (Nat × Nat) := [(4841, 4842), (2672694, 2672695), (3123795, 3123796), (3240114, 3240115), (3240180, 3240181), (3241794, 3241795), (3241848, 3241849), (3241854, 3241855), (3241860, 3241861), (3242114, 3242115), (3242185, 3242186), (3242430, 3242431), (3242454, 3242455)]
kernel_rfl DEC_ord.st1.fh120 : DEC_ord.st1.s121.heap = setAll DEC_ord.st1.s120.heap (rangesOf DEC_ord.st1.s121.heap DEC_ord.st1.fR120 ++ freshOf DEC_ord.st1.s121.heap DEC_ord.st1.s120.next DEC_ord.st1.s121.next)
kernel_rfl DEC_ord.st1.fb120 : footRB DEC_ord.st1.s120 DEC_ord.st1.s121 DEC_ord.st1.fR120 = true
kernel_rfl DEC_ord.st1.fc120 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s120.next && Nat.ble DEC_ord.st1.s121.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR120 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa121 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s121 :=
  DEC_ord.st1.fa120.step (stageFoot_ofRF DEC_ord.st1.fh120 DEC_ord.st1.fb120) (incl_of_footW DEC_ord.st1.fb120 DEC_ord.st1.fc120)

def DEC_ord.st1.fR121 : List (Nat × Nat) := [(2672694, 2672695), (3095648, 3095649), (3095700, 3095701), (3242545, 3242548), (3242611, 3242618), (3242934, 3242935), (3243344, 3243345), (3243379, 3243380), (3243414, 3243415), (3243439, 3243441), (3243452, 3243454), (3243516, 3243517), (3243527, 3243528)]
kernel_rfl DEC_ord.st1.fh121 : DEC_ord.st1.s122.heap = setAll DEC_ord.st1.s121.heap (rangesOf DEC_ord.st1.s122.heap DEC_ord.st1.fR121 ++ freshOf DEC_ord.st1.s122.heap DEC_ord.st1.s121.next DEC_ord.st1.s122.next)
kernel_rfl DEC_ord.st1.fb121 : footRB DEC_ord.st1.s121 DEC_ord.st1.s122 DEC_ord.st1.fR121 = true
kernel_rfl DEC_ord.st1.fc121 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s121.next && Nat.ble DEC_ord.st1.s122.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR121 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa122 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s122 :=
  DEC_ord.st1.fa121.step (stageFoot_ofRF DEC_ord.st1.fh121 DEC_ord.st1.fb121) (incl_of_footW DEC_ord.st1.fb121 DEC_ord.st1.fc121)

def DEC_ord.st1.fR122 : List (Nat × Nat) := [(3123795, 3123796), (3242506, 3242507), (3242573, 3242574), (3243966, 3243967), (3244024, 3244025), (3244030, 3244031), (3244036, 3244037), (3244290, 3244291), (3244311, 3244312), (3244361, 3244362), (3244379, 3244381), (3244413, 3244414), (3244416, 3244426), (3244498, 3244499)]
kernel_rfl DEC_ord.st1.fh122 : DEC_ord.st1.s123.heap = setAll DEC_ord.st1.s122.heap (rangesOf DEC_ord.st1.s123.heap DEC_ord.st1.fR122 ++ freshOf DEC_ord.st1.s123.heap DEC_ord.st1.s122.next DEC_ord.st1.s123.next)
kernel_rfl DEC_ord.st1.fb122 : footRB DEC_ord.st1.s122 DEC_ord.st1.s123 DEC_ord.st1.fR122 = true
kernel_rfl DEC_ord.st1.fc122 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s122.next && Nat.ble DEC_ord.st1.s123.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR122 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa123 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s123 :=
  DEC_ord.st1.fa122.step (stageFoot_ofRF DEC_ord.st1.fh122 DEC_ord.st1.fb122) (incl_of_footW DEC_ord.st1.fb122 DEC_ord.st1.fc122)

def DEC_ord.st1.fR123 : List (Nat × Nat) := [(2672703, 2672704), (3097754, 3097755), (3098183, 3098184), (3244742, 3244745), (3244790, 3244795), (3244984, 3244985), (3245209, 3245210), (3245295, 3245296), (3245384, 3245385), (3245422, 3245429), (3245467, 3245470), (3245522, 3245523)]
kernel_rfl DEC_ord.st1.fh123 : DEC_ord.st1.s124.heap = setAll DEC_ord.st1.s123.heap (rangesOf DEC_ord.st1.s124.heap DEC_ord.st1.fR123 ++ freshOf DEC_ord.st1.s124.heap DEC_ord.st1.s123.next DEC_ord.st1.s124.next)
kernel_rfl DEC_ord.st1.fb123 : footRB DEC_ord.st1.s123 DEC_ord.st1.s124 DEC_ord.st1.fR123 = true
kernel_rfl DEC_ord.st1.fc123 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s123.next && Nat.ble DEC_ord.st1.s124.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR123 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa124 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s124 :=
  DEC_ord.st1.fa123.step (stageFoot_ofRF DEC_ord.st1.fh123 DEC_ord.st1.fb123) (incl_of_footW DEC_ord.st1.fb123 DEC_ord.st1.fc123)

def DEC_ord.st1.fR124 : List (Nat × Nat) := [(3123795, 3123796), (3244682, 3244683), (3244770, 3244771), (3246384, 3246385), (3246438, 3246439), (3246444, 3246445), (3246450, 3246451), (3246458, 3246459), (3246469, 3246473)]
kernel_rfl DEC_ord.st1.fh124 : DEC_ord.st1.s125.heap = setAll DEC_ord.st1.s124.heap (rangesOf DEC_ord.st1.s125.heap DEC_ord.st1.fR124 ++ freshOf DEC_ord.st1.s125.heap DEC_ord.st1.s124.next DEC_ord.st1.s125.next)
kernel_rfl DEC_ord.st1.fb124 : footRB DEC_ord.st1.s124 DEC_ord.st1.s125 DEC_ord.st1.fR124 = true
kernel_rfl DEC_ord.st1.fc124 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s124.next && Nat.ble DEC_ord.st1.s125.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR124 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa125 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s125 :=
  DEC_ord.st1.fa124.step (stageFoot_ofRF DEC_ord.st1.fh124 DEC_ord.st1.fb124) (incl_of_footW DEC_ord.st1.fb124 DEC_ord.st1.fc124)

def DEC_ord.st1.fR125 : List (Nat × Nat) := [(2672708, 2672709), (3100046, 3100047), (3100475, 3100476), (3247178, 3247184), (3247376, 3247377), (3247392, 3247393), (3247444, 3247446), (3247447, 3247448)]
kernel_rfl DEC_ord.st1.fh125 : DEC_ord.st1.s126.heap = setAll DEC_ord.st1.s125.heap (rangesOf DEC_ord.st1.s126.heap DEC_ord.st1.fR125 ++ freshOf DEC_ord.st1.s126.heap DEC_ord.st1.s125.next DEC_ord.st1.s126.next)
kernel_rfl DEC_ord.st1.fb125 : footRB DEC_ord.st1.s125 DEC_ord.st1.s126 DEC_ord.st1.fR125 = true
kernel_rfl DEC_ord.st1.fc125 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s125.next && Nat.ble DEC_ord.st1.s126.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR125 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa126 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s126 :=
  DEC_ord.st1.fa125.step (stageFoot_ofRF DEC_ord.st1.fh125 DEC_ord.st1.fb125) (incl_of_footW DEC_ord.st1.fb125 DEC_ord.st1.fc125)

def DEC_ord.st1.fR126 : List (Nat × Nat) := [(3247134, 3247137), (3247184, 3247187), (3247501, 3247502), (3248374, 3248375), (3248460, 3248461)]
kernel_rfl DEC_ord.st1.fh126 : DEC_ord.st1.s127.heap = setAll DEC_ord.st1.s126.heap (rangesOf DEC_ord.st1.s127.heap DEC_ord.st1.fR126 ++ freshOf DEC_ord.st1.s127.heap DEC_ord.st1.s126.next DEC_ord.st1.s127.next)
kernel_rfl DEC_ord.st1.fb126 : footRB DEC_ord.st1.s126 DEC_ord.st1.s127 DEC_ord.st1.fR126 = true
kernel_rfl DEC_ord.st1.fc126 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s126.next && Nat.ble DEC_ord.st1.s127.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR126 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa127 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s127 :=
  DEC_ord.st1.fa126.step (stageFoot_ofRF DEC_ord.st1.fh126 DEC_ord.st1.fb126) (incl_of_footW DEC_ord.st1.fb126 DEC_ord.st1.fc126)

def DEC_ord.st1.fR127 : List (Nat × Nat) := [(2672713, 2672714), (3102238, 3102239), (3123795, 3123796), (3247096, 3247097), (3247162, 3247163), (3248676, 3248677)]
kernel_rfl DEC_ord.st1.fh127 : DEC_ord.st1.s128.heap = setAll DEC_ord.st1.s127.heap (rangesOf DEC_ord.st1.s128.heap DEC_ord.st1.fR127 ++ freshOf DEC_ord.st1.s128.heap DEC_ord.st1.s127.next DEC_ord.st1.s128.next)
kernel_rfl DEC_ord.st1.fb127 : footRB DEC_ord.st1.s127 DEC_ord.st1.s128 DEC_ord.st1.fR127 = true
kernel_rfl DEC_ord.st1.fc127 : (Nat.ble DEC_ord.st1.s0.next DEC_ord.st1.s127.next && Nat.ble DEC_ord.st1.s128.next DEC_ord.st1.s150.next && coverB DEC_ord.st1.fR127 DEC_ord.st1.wrR DEC_ord.st1.s0.next) = true
theorem DEC_ord.st1.fa128 : FootAcc DEC_ord.st1.wr DEC_ord.st1.s150 DEC_ord.st1.s0 DEC_ord.st1.s128 :=
  DEC_ord.st1.fa127.step (stageFoot_ofRF DEC_ord.st1.fh127 DEC_ord.st1.fb127) (incl_of_footW DEC_ord.st1.fb127 DEC_ord.st1.fc127)

end Host.Load.Run.Tpl

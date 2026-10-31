import host.sim.template.a4dec_clearFill.st1.FootS1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearFill.st1.fR64 : List (Nat × Nat) := [(4841, 4842), (2672508, 2672509), (3039368, 3039369), (3039420, 3039421), (3186266, 3186269), (3186329, 3186330), (3186332, 3186339), (3186655, 3186656), (3186999, 3187000), (3187065, 3187066), (3187100, 3187101)]
kernel_rfl DEC_clearFill.st1.fh64 : DEC_clearFill.st1.s65.heap = setAll DEC_clearFill.st1.s64.heap (rangesOf DEC_clearFill.st1.s65.heap DEC_clearFill.st1.fR64 ++ freshOf DEC_clearFill.st1.s65.heap DEC_clearFill.st1.s64.next DEC_clearFill.st1.s65.next)
kernel_rfl DEC_clearFill.st1.fb64 : footRB DEC_clearFill.st1.s64 DEC_clearFill.st1.s65 DEC_clearFill.st1.fR64 = true
kernel_rfl DEC_clearFill.st1.fc64 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s64.next && Nat.ble DEC_clearFill.st1.s65.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR64 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa65 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s65 :=
  DEC_clearFill.st1.fa64.step (stageFoot_ofRF DEC_clearFill.st1.fh64 DEC_clearFill.st1.fb64) (incl_of_footW DEC_clearFill.st1.fb64 DEC_clearFill.st1.fc64)

def DEC_clearFill.st1.fR65 : List (Nat × Nat) := [(3123796, 3123797), (3186227, 3186228), (3186294, 3186295), (3187687, 3187688), (3187745, 3187746), (3187751, 3187752), (3187757, 3187758), (3188011, 3188012), (3188032, 3188033), (3188082, 3188083), (3188100, 3188102)]
kernel_rfl DEC_clearFill.st1.fh65 : DEC_clearFill.st1.s66.heap = setAll DEC_clearFill.st1.s65.heap (rangesOf DEC_clearFill.st1.s66.heap DEC_clearFill.st1.fR65 ++ freshOf DEC_clearFill.st1.s66.heap DEC_clearFill.st1.s65.next DEC_clearFill.st1.s66.next)
kernel_rfl DEC_clearFill.st1.fb65 : footRB DEC_clearFill.st1.s65 DEC_clearFill.st1.s66 DEC_clearFill.st1.fR65 = true
kernel_rfl DEC_clearFill.st1.fc65 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s65.next && Nat.ble DEC_clearFill.st1.s66.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR65 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa66 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s66 :=
  DEC_clearFill.st1.fa65.step (stageFoot_ofRF DEC_clearFill.st1.fh65 DEC_clearFill.st1.fb65) (incl_of_footW DEC_clearFill.st1.fb65 DEC_clearFill.st1.fc65)

def DEC_clearFill.st1.fR66 : List (Nat × Nat) := [(2672517, 2672518), (3041474, 3041475), (3041903, 3041904), (3188509, 3188515), (3188705, 3188706), (3188930, 3188931), (3189016, 3189017), (3189032, 3189033), (3189084, 3189086), (3189087, 3189088), (3189104, 3189105)]
kernel_rfl DEC_clearFill.st1.fh66 : DEC_clearFill.st1.s67.heap = setAll DEC_clearFill.st1.s66.heap (rangesOf DEC_clearFill.st1.s67.heap DEC_clearFill.st1.fR66 ++ freshOf DEC_clearFill.st1.s67.heap DEC_clearFill.st1.s66.next DEC_clearFill.st1.s67.next)
kernel_rfl DEC_clearFill.st1.fb66 : footRB DEC_clearFill.st1.s66 DEC_clearFill.st1.s67 DEC_clearFill.st1.fR66 = true
kernel_rfl DEC_clearFill.st1.fc66 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s66.next && Nat.ble DEC_clearFill.st1.s67.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR66 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa67 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s67 :=
  DEC_clearFill.st1.fa66.step (stageFoot_ofRF DEC_clearFill.st1.fh66 DEC_clearFill.st1.fb66) (incl_of_footW DEC_clearFill.st1.fb66 DEC_clearFill.st1.fc66)

def DEC_clearFill.st1.fR67 : List (Nat × Nat) := [(3123796, 3123797), (3188403, 3188404), (3188463, 3188466), (3188491, 3188492), (3188515, 3188516), (3189922, 3189923), (3189947, 3189948), (3190023, 3190028)]
kernel_rfl DEC_clearFill.st1.fh67 : DEC_clearFill.st1.s68.heap = setAll DEC_clearFill.st1.s67.heap (rangesOf DEC_clearFill.st1.s68.heap DEC_clearFill.st1.fR67 ++ freshOf DEC_clearFill.st1.s68.heap DEC_clearFill.st1.s67.next DEC_clearFill.st1.s68.next)
kernel_rfl DEC_clearFill.st1.fb67 : footRB DEC_clearFill.st1.s67 DEC_clearFill.st1.s68 DEC_clearFill.st1.fR67 = true
kernel_rfl DEC_clearFill.st1.fc67 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s67.next && Nat.ble DEC_clearFill.st1.s68.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR67 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa68 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s68 :=
  DEC_clearFill.st1.fa67.step (stageFoot_ofRF DEC_clearFill.st1.fh67 DEC_clearFill.st1.fb67) (incl_of_footW DEC_clearFill.st1.fb67 DEC_clearFill.st1.fc67)

def DEC_clearFill.st1.fR68 : List (Nat × Nat) := [(2672522, 2672523), (3043866, 3043867), (3190898, 3190903), (3190939, 3190940), (3191007, 3191008), (3191010, 3191020), (3191068, 3191069)]
kernel_rfl DEC_clearFill.st1.fh68 : DEC_clearFill.st1.s69.heap = setAll DEC_clearFill.st1.s68.heap (rangesOf DEC_clearFill.st1.s69.heap DEC_clearFill.st1.fR68 ++ freshOf DEC_clearFill.st1.s69.heap DEC_clearFill.st1.s68.next DEC_clearFill.st1.s69.next)
kernel_rfl DEC_clearFill.st1.fb68 : footRB DEC_clearFill.st1.s68 DEC_clearFill.st1.s69 DEC_clearFill.st1.fR68 = true
kernel_rfl DEC_clearFill.st1.fc68 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s68.next && Nat.ble DEC_clearFill.st1.s69.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR68 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa69 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s69 :=
  DEC_clearFill.st1.fa68.step (stageFoot_ofRF DEC_clearFill.st1.fh68 DEC_clearFill.st1.fb68) (incl_of_footW DEC_clearFill.st1.fb68 DEC_clearFill.st1.fc68)

def DEC_clearFill.st1.fR69 : List (Nat × Nat) := [(2672522, 2672523), (3044295, 3044296), (3190855, 3190858), (3190903, 3190908), (3191097, 3191098), (3191322, 3191323), (3191408, 3191409), (3191497, 3191498), (3191540, 3191542), (3191863, 3191864), (3191869, 3191870), (3191875, 3191876), (3191904, 3191906), (3191950, 3191951), (3191994, 3191995), (3192016, 3192018), (3192057, 3192058), (3192089, 3192090), (3192092, 3192102)]
kernel_rfl DEC_clearFill.st1.fh69 : DEC_clearFill.st1.s70.heap = setAll DEC_clearFill.st1.s69.heap (rangesOf DEC_clearFill.st1.s70.heap DEC_clearFill.st1.fR69 ++ freshOf DEC_clearFill.st1.s70.heap DEC_clearFill.st1.s69.next DEC_clearFill.st1.s70.next)
kernel_rfl DEC_clearFill.st1.fb69 : footRB DEC_clearFill.st1.s69 DEC_clearFill.st1.s70 DEC_clearFill.st1.fR69 = true
kernel_rfl DEC_clearFill.st1.fc69 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s69.next && Nat.ble DEC_clearFill.st1.s70.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR69 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa70 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s70 :=
  DEC_clearFill.st1.fa69.step (stageFoot_ofRF DEC_clearFill.st1.fh69 DEC_clearFill.st1.fb69) (incl_of_footW DEC_clearFill.st1.fb69 DEC_clearFill.st1.fc69)

def DEC_clearFill.st1.fR70 : List (Nat × Nat) := [(3123796, 3123797), (3190817, 3190818), (3190883, 3190884), (3192497, 3192498), (3192551, 3192552), (3192557, 3192558), (3192563, 3192564), (3192817, 3192818), (3192838, 3192839), (3192888, 3192889), (3192910, 3192912), (3192944, 3192945), (3192947, 3192957), (3193029, 3193030)]
kernel_rfl DEC_clearFill.st1.fh70 : DEC_clearFill.st1.s71.heap = setAll DEC_clearFill.st1.s70.heap (rangesOf DEC_clearFill.st1.s71.heap DEC_clearFill.st1.fR70 ++ freshOf DEC_clearFill.st1.s71.heap DEC_clearFill.st1.s70.next DEC_clearFill.st1.s71.next)
kernel_rfl DEC_clearFill.st1.fb70 : footRB DEC_clearFill.st1.s70 DEC_clearFill.st1.s71 DEC_clearFill.st1.fR70 = true
kernel_rfl DEC_clearFill.st1.fc70 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s70.next && Nat.ble DEC_clearFill.st1.s71.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR70 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa71 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s71 :=
  DEC_clearFill.st1.fa70.step (stageFoot_ofRF DEC_clearFill.st1.fh70 DEC_clearFill.st1.fb70) (incl_of_footW DEC_clearFill.st1.fb70 DEC_clearFill.st1.fc70)

def DEC_clearFill.st1.fR71 : List (Nat × Nat) := [(2672527, 2672528), (3046262, 3046263), (3046691, 3046692), (3193251, 3193254), (3193299, 3193304), (3193493, 3193494), (3193718, 3193719), (3193804, 3193805), (3193893, 3193894), (3193931, 3193938), (3193977, 3193979), (3194031, 3194032), (3194054, 3194057), (3194059, 3194061)]
kernel_rfl DEC_clearFill.st1.fh71 : DEC_clearFill.st1.s72.heap = setAll DEC_clearFill.st1.s71.heap (rangesOf DEC_clearFill.st1.s72.heap DEC_clearFill.st1.fR71 ++ freshOf DEC_clearFill.st1.s72.heap DEC_clearFill.st1.s71.next DEC_clearFill.st1.s72.next)
kernel_rfl DEC_clearFill.st1.fb71 : footRB DEC_clearFill.st1.s71 DEC_clearFill.st1.s72 DEC_clearFill.st1.fR71 = true
kernel_rfl DEC_clearFill.st1.fc71 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s71.next && Nat.ble DEC_clearFill.st1.s72.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR71 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa72 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s72 :=
  DEC_clearFill.st1.fa71.step (stageFoot_ofRF DEC_clearFill.st1.fh71 DEC_clearFill.st1.fb71) (incl_of_footW DEC_clearFill.st1.fb71 DEC_clearFill.st1.fc71)

def DEC_clearFill.st1.fR72 : List (Nat × Nat) := [(3123796, 3123797), (3193213, 3193214), (3193279, 3193280), (3194893, 3194894), (3194947, 3194948), (3194953, 3194954), (3194959, 3194960), (3194967, 3194968), (3194978, 3194982)]
kernel_rfl DEC_clearFill.st1.fh72 : DEC_clearFill.st1.s73.heap = setAll DEC_clearFill.st1.s72.heap (rangesOf DEC_clearFill.st1.s73.heap DEC_clearFill.st1.fR72 ++ freshOf DEC_clearFill.st1.s73.heap DEC_clearFill.st1.s72.next DEC_clearFill.st1.s73.next)
kernel_rfl DEC_clearFill.st1.fb72 : footRB DEC_clearFill.st1.s72 DEC_clearFill.st1.s73 DEC_clearFill.st1.fR72 = true
kernel_rfl DEC_clearFill.st1.fc72 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s72.next && Nat.ble DEC_clearFill.st1.s73.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR72 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa73 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s73 :=
  DEC_clearFill.st1.fa72.step (stageFoot_ofRF DEC_clearFill.st1.fh72 DEC_clearFill.st1.fb72) (incl_of_footW DEC_clearFill.st1.fb72 DEC_clearFill.st1.fc72)

def DEC_clearFill.st1.fR73 : List (Nat × Nat) := [(4841, 4842), (2672539, 2672540), (3048746, 3048747), (3048798, 3048799), (3195704, 3195716), (3195843, 3195844), (3195877, 3195878), (3195938, 3195939), (3195992, 3195996)]
kernel_rfl DEC_clearFill.st1.fh73 : DEC_clearFill.st1.s74.heap = setAll DEC_clearFill.st1.s73.heap (rangesOf DEC_clearFill.st1.s74.heap DEC_clearFill.st1.fR73 ++ freshOf DEC_clearFill.st1.s74.heap DEC_clearFill.st1.s73.next DEC_clearFill.st1.s74.next)
kernel_rfl DEC_clearFill.st1.fb73 : footRB DEC_clearFill.st1.s73 DEC_clearFill.st1.s74 DEC_clearFill.st1.fR73 = true
kernel_rfl DEC_clearFill.st1.fc73 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s73.next && Nat.ble DEC_clearFill.st1.s74.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR73 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa74 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s74 :=
  DEC_clearFill.st1.fa73.step (stageFoot_ofRF DEC_clearFill.st1.fh73 DEC_clearFill.st1.fb73) (incl_of_footW DEC_clearFill.st1.fb73 DEC_clearFill.st1.fc73)

def DEC_clearFill.st1.fR74 : List (Nat × Nat) := [(3123796, 3123797), (3195605, 3195606), (3195644, 3195647), (3195672, 3195673), (3195716, 3195717), (3196980, 3196981), (3196992, 3196993), (3197010, 3197011), (3197027, 3197028)]
kernel_rfl DEC_clearFill.st1.fh74 : DEC_clearFill.st1.s75.heap = setAll DEC_clearFill.st1.s74.heap (rangesOf DEC_clearFill.st1.s75.heap DEC_clearFill.st1.fR74 ++ freshOf DEC_clearFill.st1.s75.heap DEC_clearFill.st1.s74.next DEC_clearFill.st1.s75.next)
kernel_rfl DEC_clearFill.st1.fb74 : footRB DEC_clearFill.st1.s74 DEC_clearFill.st1.s75 DEC_clearFill.st1.fR74 = true
kernel_rfl DEC_clearFill.st1.fc74 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s74.next && Nat.ble DEC_clearFill.st1.s75.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR74 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa75 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s75 :=
  DEC_clearFill.st1.fa74.step (stageFoot_ofRF DEC_clearFill.st1.fh74 DEC_clearFill.st1.fb74) (incl_of_footW DEC_clearFill.st1.fb74 DEC_clearFill.st1.fc74)

def DEC_clearFill.st1.fR75 : List (Nat × Nat) := [(2672548, 2672549), (3050856, 3050857), (3197888, 3197893), (3197929, 3197930), (3197997, 3197998), (3198000, 3198010)]
kernel_rfl DEC_clearFill.st1.fh75 : DEC_clearFill.st1.s76.heap = setAll DEC_clearFill.st1.s75.heap (rangesOf DEC_clearFill.st1.s76.heap DEC_clearFill.st1.fR75 ++ freshOf DEC_clearFill.st1.s76.heap DEC_clearFill.st1.s75.next DEC_clearFill.st1.s76.next)
kernel_rfl DEC_clearFill.st1.fb75 : footRB DEC_clearFill.st1.s75 DEC_clearFill.st1.s76 DEC_clearFill.st1.fR75 = true
kernel_rfl DEC_clearFill.st1.fc75 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s75.next && Nat.ble DEC_clearFill.st1.s76.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR75 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa76 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s76 :=
  DEC_clearFill.st1.fa75.step (stageFoot_ofRF DEC_clearFill.st1.fh75 DEC_clearFill.st1.fb75) (incl_of_footW DEC_clearFill.st1.fb75 DEC_clearFill.st1.fc75)

def DEC_clearFill.st1.fR76 : List (Nat × Nat) := [(2672548, 2672549), (3051285, 3051286), (3197845, 3197848), (3197893, 3197898), (3198087, 3198088), (3198312, 3198313), (3198398, 3198399), (3198487, 3198488), (3198530, 3198532), (3198853, 3198854), (3198859, 3198860), (3198865, 3198866), (3198894, 3198896), (3198940, 3198941), (3198984, 3198985), (3199006, 3199008), (3199047, 3199048), (3199055, 3199057)]
kernel_rfl DEC_clearFill.st1.fh76 : DEC_clearFill.st1.s77.heap = setAll DEC_clearFill.st1.s76.heap (rangesOf DEC_clearFill.st1.s77.heap DEC_clearFill.st1.fR76 ++ freshOf DEC_clearFill.st1.s77.heap DEC_clearFill.st1.s76.next DEC_clearFill.st1.s77.next)
kernel_rfl DEC_clearFill.st1.fb76 : footRB DEC_clearFill.st1.s76 DEC_clearFill.st1.s77 DEC_clearFill.st1.fR76 = true
kernel_rfl DEC_clearFill.st1.fc76 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s76.next && Nat.ble DEC_clearFill.st1.s77.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR76 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa77 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s77 :=
  DEC_clearFill.st1.fa76.step (stageFoot_ofRF DEC_clearFill.st1.fh76 DEC_clearFill.st1.fb76) (incl_of_footW DEC_clearFill.st1.fb76 DEC_clearFill.st1.fc76)

def DEC_clearFill.st1.fR77 : List (Nat × Nat) := [(3123796, 3123797), (3197785, 3197786), (3197873, 3197874), (3199487, 3199488), (3199541, 3199542), (3199547, 3199548), (3199553, 3199554), (3199807, 3199808), (3199828, 3199829), (3199878, 3199879), (3199900, 3199902), (3199934, 3199935), (3199937, 3199947)]
kernel_rfl DEC_clearFill.st1.fh77 : DEC_clearFill.st1.s78.heap = setAll DEC_clearFill.st1.s77.heap (rangesOf DEC_clearFill.st1.s78.heap DEC_clearFill.st1.fR77 ++ freshOf DEC_clearFill.st1.s78.heap DEC_clearFill.st1.s77.next DEC_clearFill.st1.s78.next)
kernel_rfl DEC_clearFill.st1.fb77 : footRB DEC_clearFill.st1.s77 DEC_clearFill.st1.s78 DEC_clearFill.st1.fR77 = true
kernel_rfl DEC_clearFill.st1.fc77 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s77.next && Nat.ble DEC_clearFill.st1.s78.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR77 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa78 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s78 :=
  DEC_clearFill.st1.fa77.step (stageFoot_ofRF DEC_clearFill.st1.fh77 DEC_clearFill.st1.fb77) (incl_of_footW DEC_clearFill.st1.fb77 DEC_clearFill.st1.fc77)

def DEC_clearFill.st1.fR78 : List (Nat × Nat) := [(2672553, 2672554), (3053252, 3053253), (3053681, 3053682), (3200241, 3200242), (3200289, 3200294), (3200483, 3200484), (3200708, 3200709), (3200794, 3200795), (3200883, 3200884), (3200921, 3200928), (3200966, 3200969), (3200987, 3200989), (3200995, 3200996)]
kernel_rfl DEC_clearFill.st1.fh78 : DEC_clearFill.st1.s79.heap = setAll DEC_clearFill.st1.s78.heap (rangesOf DEC_clearFill.st1.s79.heap DEC_clearFill.st1.fR78 ++ freshOf DEC_clearFill.st1.s79.heap DEC_clearFill.st1.s78.next DEC_clearFill.st1.s79.next)
kernel_rfl DEC_clearFill.st1.fb78 : footRB DEC_clearFill.st1.s78 DEC_clearFill.st1.s79 DEC_clearFill.st1.fR78 = true
kernel_rfl DEC_clearFill.st1.fc78 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s78.next && Nat.ble DEC_clearFill.st1.s79.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR78 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa79 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s79 :=
  DEC_clearFill.st1.fa78.step (stageFoot_ofRF DEC_clearFill.st1.fh78 DEC_clearFill.st1.fb78) (incl_of_footW DEC_clearFill.st1.fb78 DEC_clearFill.st1.fc78)

def DEC_clearFill.st1.fR79 : List (Nat × Nat) := [(3123796, 3123797), (3200203, 3200204), (3200242, 3200244), (3200269, 3200270), (3201883, 3201884), (3201932, 3201934), (3201937, 3201938)]
kernel_rfl DEC_clearFill.st1.fh79 : DEC_clearFill.st1.s80.heap = setAll DEC_clearFill.st1.s79.heap (rangesOf DEC_clearFill.st1.s80.heap DEC_clearFill.st1.fR79 ++ freshOf DEC_clearFill.st1.s80.heap DEC_clearFill.st1.s79.next DEC_clearFill.st1.s80.next)
kernel_rfl DEC_clearFill.st1.fb79 : footRB DEC_clearFill.st1.s79 DEC_clearFill.st1.s80 DEC_clearFill.st1.fR79 = true
kernel_rfl DEC_clearFill.st1.fc79 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s79.next && Nat.ble DEC_clearFill.st1.s80.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR79 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa80 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s80 :=
  DEC_clearFill.st1.fa79.step (stageFoot_ofRF DEC_clearFill.st1.fh79 DEC_clearFill.st1.fb79) (incl_of_footW DEC_clearFill.st1.fb79 DEC_clearFill.st1.fc79)

def DEC_clearFill.st1.fR80 : List (Nat × Nat) := [(2672558, 2672559), (3055648, 3055649), (3202681, 3202685), (3202907, 3202911)]
kernel_rfl DEC_clearFill.st1.fh80 : DEC_clearFill.st1.s81.heap = setAll DEC_clearFill.st1.s80.heap (rangesOf DEC_clearFill.st1.s81.heap DEC_clearFill.st1.fR80 ++ freshOf DEC_clearFill.st1.s81.heap DEC_clearFill.st1.s80.next DEC_clearFill.st1.s81.next)
kernel_rfl DEC_clearFill.st1.fb80 : footRB DEC_clearFill.st1.s80 DEC_clearFill.st1.s81 DEC_clearFill.st1.fR80 = true
kernel_rfl DEC_clearFill.st1.fc80 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s80.next && Nat.ble DEC_clearFill.st1.s81.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR80 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa81 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s81 :=
  DEC_clearFill.st1.fa80.step (stageFoot_ofRF DEC_clearFill.st1.fh80 DEC_clearFill.st1.fb80) (incl_of_footW DEC_clearFill.st1.fb80 DEC_clearFill.st1.fc80)

def DEC_clearFill.st1.fR81 : List (Nat × Nat) := [(2672558, 2672559), (3056077, 3056078), (3202637, 3202640), (3202685, 3202690), (3202879, 3202880), (3203104, 3203105), (3203190, 3203191), (3203279, 3203280), (3203322, 3203324), (3203645, 3203646), (3203651, 3203652), (3203657, 3203658), (3203686, 3203688), (3203732, 3203733), (3203776, 3203777), (3203798, 3203800), (3203839, 3203840), (3203877, 3203884), (3203970, 3203971)]
kernel_rfl DEC_clearFill.st1.fh81 : DEC_clearFill.st1.s82.heap = setAll DEC_clearFill.st1.s81.heap (rangesOf DEC_clearFill.st1.s82.heap DEC_clearFill.st1.fR81 ++ freshOf DEC_clearFill.st1.s82.heap DEC_clearFill.st1.s81.next DEC_clearFill.st1.s82.next)
kernel_rfl DEC_clearFill.st1.fb81 : footRB DEC_clearFill.st1.s81 DEC_clearFill.st1.s82 DEC_clearFill.st1.fR81 = true
kernel_rfl DEC_clearFill.st1.fc81 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s81.next && Nat.ble DEC_clearFill.st1.s82.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR81 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa82 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s82 :=
  DEC_clearFill.st1.fa81.step (stageFoot_ofRF DEC_clearFill.st1.fh81 DEC_clearFill.st1.fb81) (incl_of_footW DEC_clearFill.st1.fb81 DEC_clearFill.st1.fc81)

def DEC_clearFill.st1.fR82 : List (Nat × Nat) := [(4841, 4842), (3123796, 3123797), (3202599, 3202600), (3202665, 3202666), (3204279, 3204280), (3204333, 3204334), (3204339, 3204340), (3204345, 3204346), (3204599, 3204600), (3204620, 3204621), (3204670, 3204671), (3204689, 3204690), (3204832, 3204833), (3204861, 3204862), (3204864, 3204874), (3204881, 3204882)]
kernel_rfl DEC_clearFill.st1.fh82 : DEC_clearFill.st1.s83.heap = setAll DEC_clearFill.st1.s82.heap (rangesOf DEC_clearFill.st1.s83.heap DEC_clearFill.st1.fR82 ++ freshOf DEC_clearFill.st1.s83.heap DEC_clearFill.st1.s82.next DEC_clearFill.st1.s83.next)
kernel_rfl DEC_clearFill.st1.fb82 : footRB DEC_clearFill.st1.s82 DEC_clearFill.st1.s83 DEC_clearFill.st1.fR82 = true
kernel_rfl DEC_clearFill.st1.fc82 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s82.next && Nat.ble DEC_clearFill.st1.s83.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR82 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa83 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s83 :=
  DEC_clearFill.st1.fa82.step (stageFoot_ofRF DEC_clearFill.st1.fh82 DEC_clearFill.st1.fb82) (incl_of_footW DEC_clearFill.st1.fb82 DEC_clearFill.st1.fc82)

def DEC_clearFill.st1.fR83 : List (Nat × Nat) := [(2672570, 2672571), (3058132, 3058133), (3058184, 3058185), (3205030, 3205033), (3205096, 3205103), (3205419, 3205420), (3205829, 3205830), (3205864, 3205865), (3205899, 3205900)]
kernel_rfl DEC_clearFill.st1.fh83 : DEC_clearFill.st1.s84.heap = setAll DEC_clearFill.st1.s83.heap (rangesOf DEC_clearFill.st1.s84.heap DEC_clearFill.st1.fR83 ++ freshOf DEC_clearFill.st1.s84.heap DEC_clearFill.st1.s83.next DEC_clearFill.st1.s84.next)
kernel_rfl DEC_clearFill.st1.fb83 : footRB DEC_clearFill.st1.s83 DEC_clearFill.st1.s84 DEC_clearFill.st1.fR83 = true
kernel_rfl DEC_clearFill.st1.fc83 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s83.next && Nat.ble DEC_clearFill.st1.s84.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR83 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa84 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s84 :=
  DEC_clearFill.st1.fa83.step (stageFoot_ofRF DEC_clearFill.st1.fh83 DEC_clearFill.st1.fb83) (incl_of_footW DEC_clearFill.st1.fb83 DEC_clearFill.st1.fc83)

def DEC_clearFill.st1.fR84 : List (Nat × Nat) := [(3123796, 3123797), (3204991, 3204992), (3205058, 3205059), (3206451, 3206452), (3206509, 3206510), (3206515, 3206516), (3206521, 3206522), (3206775, 3206776), (3206796, 3206797), (3206846, 3206847), (3206864, 3206866), (3206898, 3206899), (3206901, 3206911)]
kernel_rfl DEC_clearFill.st1.fh84 : DEC_clearFill.st1.s85.heap = setAll DEC_clearFill.st1.s84.heap (rangesOf DEC_clearFill.st1.s85.heap DEC_clearFill.st1.fR84 ++ freshOf DEC_clearFill.st1.s85.heap DEC_clearFill.st1.s84.next DEC_clearFill.st1.s85.next)
kernel_rfl DEC_clearFill.st1.fb84 : footRB DEC_clearFill.st1.s84 DEC_clearFill.st1.s85 DEC_clearFill.st1.fR84 = true
kernel_rfl DEC_clearFill.st1.fc84 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s84.next && Nat.ble DEC_clearFill.st1.s85.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR84 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa85 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s85 :=
  DEC_clearFill.st1.fa84.step (stageFoot_ofRF DEC_clearFill.st1.fh84 DEC_clearFill.st1.fb84) (incl_of_footW DEC_clearFill.st1.fb84 DEC_clearFill.st1.fc84)

def DEC_clearFill.st1.fR85 : List (Nat × Nat) := [(2672579, 2672580), (3060238, 3060239), (3060667, 3060668), (3207275, 3207280), (3207469, 3207470), (3207694, 3207695), (3207780, 3207781), (3207869, 3207870), (3207900, 3207914), (3207917, 3207918)]
kernel_rfl DEC_clearFill.st1.fh85 : DEC_clearFill.st1.s86.heap = setAll DEC_clearFill.st1.s85.heap (rangesOf DEC_clearFill.st1.s86.heap DEC_clearFill.st1.fR85 ++ freshOf DEC_clearFill.st1.s86.heap DEC_clearFill.st1.s85.next DEC_clearFill.st1.s86.next)
kernel_rfl DEC_clearFill.st1.fb85 : footRB DEC_clearFill.st1.s85 DEC_clearFill.st1.s86 DEC_clearFill.st1.fR85 = true
kernel_rfl DEC_clearFill.st1.fc85 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s85.next && Nat.ble DEC_clearFill.st1.s86.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR85 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa86 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s86 :=
  DEC_clearFill.st1.fa85.step (stageFoot_ofRF DEC_clearFill.st1.fh85 DEC_clearFill.st1.fb85) (incl_of_footW DEC_clearFill.st1.fb85 DEC_clearFill.st1.fc85)

def DEC_clearFill.st1.fR86 : List (Nat × Nat) := [(3123796, 3123797), (3207167, 3207168), (3207227, 3207230), (3207255, 3207256), (3208869, 3208870)]
kernel_rfl DEC_clearFill.st1.fh86 : DEC_clearFill.st1.s87.heap = setAll DEC_clearFill.st1.s86.heap (rangesOf DEC_clearFill.st1.s87.heap DEC_clearFill.st1.fR86 ++ freshOf DEC_clearFill.st1.s87.heap DEC_clearFill.st1.s86.next DEC_clearFill.st1.s87.next)
kernel_rfl DEC_clearFill.st1.fb86 : footRB DEC_clearFill.st1.s86 DEC_clearFill.st1.s87 DEC_clearFill.st1.fR86 = true
kernel_rfl DEC_clearFill.st1.fc86 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s86.next && Nat.ble DEC_clearFill.st1.s87.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR86 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa87 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s87 :=
  DEC_clearFill.st1.fa86.step (stageFoot_ofRF DEC_clearFill.st1.fh86 DEC_clearFill.st1.fb86) (incl_of_footW DEC_clearFill.st1.fb86 DEC_clearFill.st1.fc86)

def DEC_clearFill.st1.fR87 : List (Nat × Nat) := [(2672584, 2672585), (3062630, 3062631), (3209662, 3209667), (3209703, 3209704), (3209782, 3209784), (3209856, 3209857)]
kernel_rfl DEC_clearFill.st1.fh87 : DEC_clearFill.st1.s88.heap = setAll DEC_clearFill.st1.s87.heap (rangesOf DEC_clearFill.st1.s88.heap DEC_clearFill.st1.fR87 ++ freshOf DEC_clearFill.st1.s88.heap DEC_clearFill.st1.s87.next DEC_clearFill.st1.s88.next)
kernel_rfl DEC_clearFill.st1.fb87 : footRB DEC_clearFill.st1.s87 DEC_clearFill.st1.s88 DEC_clearFill.st1.fR87 = true
kernel_rfl DEC_clearFill.st1.fc87 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s87.next && Nat.ble DEC_clearFill.st1.s88.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR87 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa88 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s88 :=
  DEC_clearFill.st1.fa87.step (stageFoot_ofRF DEC_clearFill.st1.fh87 DEC_clearFill.st1.fb87) (incl_of_footW DEC_clearFill.st1.fb87 DEC_clearFill.st1.fc87)

def DEC_clearFill.st1.fR88 : List (Nat × Nat) := [(2672584, 2672585), (3063059, 3063060), (3209619, 3209622), (3209667, 3209672), (3209861, 3209862), (3210086, 3210087), (3210172, 3210173), (3210261, 3210262), (3210304, 3210306), (3210627, 3210628), (3210633, 3210634), (3210639, 3210640), (3210668, 3210670), (3210714, 3210715), (3210758, 3210759), (3210780, 3210782), (3210821, 3210822), (3210853, 3210854), (3210856, 3210866), (3210918, 3210919)]
kernel_rfl DEC_clearFill.st1.fh88 : DEC_clearFill.st1.s89.heap = setAll DEC_clearFill.st1.s88.heap (rangesOf DEC_clearFill.st1.s89.heap DEC_clearFill.st1.fR88 ++ freshOf DEC_clearFill.st1.s89.heap DEC_clearFill.st1.s88.next DEC_clearFill.st1.s89.next)
kernel_rfl DEC_clearFill.st1.fb88 : footRB DEC_clearFill.st1.s88 DEC_clearFill.st1.s89 DEC_clearFill.st1.fR88 = true
kernel_rfl DEC_clearFill.st1.fc88 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s88.next && Nat.ble DEC_clearFill.st1.s89.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR88 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa89 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s89 :=
  DEC_clearFill.st1.fa88.step (stageFoot_ofRF DEC_clearFill.st1.fh88 DEC_clearFill.st1.fb88) (incl_of_footW DEC_clearFill.st1.fb88 DEC_clearFill.st1.fc88)

def DEC_clearFill.st1.fR89 : List (Nat × Nat) := [(3123796, 3123797), (3209581, 3209582), (3209647, 3209648), (3211261, 3211262), (3211315, 3211316), (3211321, 3211322), (3211327, 3211328), (3211581, 3211582), (3211602, 3211603), (3211652, 3211653), (3211670, 3211672), (3211809, 3211810), (3211814, 3211815)]
kernel_rfl DEC_clearFill.st1.fh89 : DEC_clearFill.st1.s90.heap = setAll DEC_clearFill.st1.s89.heap (rangesOf DEC_clearFill.st1.s90.heap DEC_clearFill.st1.fR89 ++ freshOf DEC_clearFill.st1.s90.heap DEC_clearFill.st1.s89.next DEC_clearFill.st1.s90.next)
kernel_rfl DEC_clearFill.st1.fb89 : footRB DEC_clearFill.st1.s89 DEC_clearFill.st1.s90 DEC_clearFill.st1.fR89 = true
kernel_rfl DEC_clearFill.st1.fc89 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s89.next && Nat.ble DEC_clearFill.st1.s90.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR89 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa90 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s90 :=
  DEC_clearFill.st1.fa89.step (stageFoot_ofRF DEC_clearFill.st1.fh89 DEC_clearFill.st1.fb89) (incl_of_footW DEC_clearFill.st1.fb89 DEC_clearFill.st1.fc89)

def DEC_clearFill.st1.fR90 : List (Nat × Nat) := [(2672589, 2672590), (3065022, 3065023), (3065451, 3065452), (3212011, 3212014), (3212059, 3212064), (3212253, 3212254), (3212478, 3212479), (3212564, 3212565), (3212653, 3212654), (3212691, 3212698), (3212737, 3212739), (3212791, 3212792), (3212816, 3212817), (3212864, 3212867), (3212868, 3212869)]
kernel_rfl DEC_clearFill.st1.fh90 : DEC_clearFill.st1.s91.heap = setAll DEC_clearFill.st1.s90.heap (rangesOf DEC_clearFill.st1.s91.heap DEC_clearFill.st1.fR90 ++ freshOf DEC_clearFill.st1.s91.heap DEC_clearFill.st1.s90.next DEC_clearFill.st1.s91.next)
kernel_rfl DEC_clearFill.st1.fb90 : footRB DEC_clearFill.st1.s90 DEC_clearFill.st1.s91 DEC_clearFill.st1.fR90 = true
kernel_rfl DEC_clearFill.st1.fc90 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s90.next && Nat.ble DEC_clearFill.st1.s91.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR90 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa91 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s91 :=
  DEC_clearFill.st1.fa90.step (stageFoot_ofRF DEC_clearFill.st1.fh90 DEC_clearFill.st1.fb90) (incl_of_footW DEC_clearFill.st1.fb90 DEC_clearFill.st1.fc90)

def DEC_clearFill.st1.fR91 : List (Nat × Nat) := [(3123796, 3123797), (3211973, 3211974), (3212039, 3212040), (3213653, 3213654), (3213707, 3213708), (3213713, 3213714), (3213719, 3213720), (3213727, 3213728), (3213740, 3213742), (3213796, 3213797)]
kernel_rfl DEC_clearFill.st1.fh91 : DEC_clearFill.st1.s92.heap = setAll DEC_clearFill.st1.s91.heap (rangesOf DEC_clearFill.st1.s92.heap DEC_clearFill.st1.fR91 ++ freshOf DEC_clearFill.st1.s92.heap DEC_clearFill.st1.s91.next DEC_clearFill.st1.s92.next)
kernel_rfl DEC_clearFill.st1.fb91 : footRB DEC_clearFill.st1.s91 DEC_clearFill.st1.s92 DEC_clearFill.st1.fR91 = true
kernel_rfl DEC_clearFill.st1.fc91 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s91.next && Nat.ble DEC_clearFill.st1.s92.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR91 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa92 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s92 :=
  DEC_clearFill.st1.fa91.step (stageFoot_ofRF DEC_clearFill.st1.fh91 DEC_clearFill.st1.fb91) (incl_of_footW DEC_clearFill.st1.fb91 DEC_clearFill.st1.fc91)

def DEC_clearFill.st1.fR92 : List (Nat × Nat) := [(4841, 4842), (2672601, 2672602), (3067506, 3067507), (3067558, 3067559), (3214466, 3214476), (3214698, 3214699), (3214762, 3214763), (3214785, 3214787), (3214788, 3214789)]
kernel_rfl DEC_clearFill.st1.fh92 : DEC_clearFill.st1.s93.heap = setAll DEC_clearFill.st1.s92.heap (rangesOf DEC_clearFill.st1.s93.heap DEC_clearFill.st1.fR92 ++ freshOf DEC_clearFill.st1.s93.heap DEC_clearFill.st1.s92.next DEC_clearFill.st1.s93.next)
kernel_rfl DEC_clearFill.st1.fb92 : footRB DEC_clearFill.st1.s92 DEC_clearFill.st1.s93 DEC_clearFill.st1.fR92 = true
kernel_rfl DEC_clearFill.st1.fc92 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s92.next && Nat.ble DEC_clearFill.st1.s93.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR92 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa93 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s93 :=
  DEC_clearFill.st1.fa92.step (stageFoot_ofRF DEC_clearFill.st1.fh92 DEC_clearFill.st1.fb92) (incl_of_footW DEC_clearFill.st1.fb92 DEC_clearFill.st1.fc92)

def DEC_clearFill.st1.fR93 : List (Nat × Nat) := [(3123796, 3123797), (3214365, 3214366), (3214404, 3214407), (3214432, 3214433), (3214476, 3214477), (3215740, 3215741), (3215752, 3215753), (3215805, 3215806)]
kernel_rfl DEC_clearFill.st1.fh93 : DEC_clearFill.st1.s94.heap = setAll DEC_clearFill.st1.s93.heap (rangesOf DEC_clearFill.st1.s94.heap DEC_clearFill.st1.fR93 ++ freshOf DEC_clearFill.st1.s94.heap DEC_clearFill.st1.s93.next DEC_clearFill.st1.s94.next)
kernel_rfl DEC_clearFill.st1.fb93 : footRB DEC_clearFill.st1.s93 DEC_clearFill.st1.s94 DEC_clearFill.st1.fR93 = true
kernel_rfl DEC_clearFill.st1.fc93 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s93.next && Nat.ble DEC_clearFill.st1.s94.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR93 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa94 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s94 :=
  DEC_clearFill.st1.fa93.step (stageFoot_ofRF DEC_clearFill.st1.fh93 DEC_clearFill.st1.fb93) (incl_of_footW DEC_clearFill.st1.fb93 DEC_clearFill.st1.fc93)

def DEC_clearFill.st1.fR94 : List (Nat × Nat) := [(2672610, 2672611), (3069612, 3069613), (3216644, 3216649), (3216685, 3216686), (3216753, 3216754), (3216756, 3216766), (3216812, 3216814)]
kernel_rfl DEC_clearFill.st1.fh94 : DEC_clearFill.st1.s95.heap = setAll DEC_clearFill.st1.s94.heap (rangesOf DEC_clearFill.st1.s95.heap DEC_clearFill.st1.fR94 ++ freshOf DEC_clearFill.st1.s95.heap DEC_clearFill.st1.s94.next DEC_clearFill.st1.s95.next)
kernel_rfl DEC_clearFill.st1.fb94 : footRB DEC_clearFill.st1.s94 DEC_clearFill.st1.s95 DEC_clearFill.st1.fR94 = true
kernel_rfl DEC_clearFill.st1.fc94 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s94.next && Nat.ble DEC_clearFill.st1.s95.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR94 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa95 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s95 :=
  DEC_clearFill.st1.fa94.step (stageFoot_ofRF DEC_clearFill.st1.fh94 DEC_clearFill.st1.fb94) (incl_of_footW DEC_clearFill.st1.fb94 DEC_clearFill.st1.fc94)

def DEC_clearFill.st1.fR95 : List (Nat × Nat) := [(2672610, 2672611), (3070041, 3070042), (3216601, 3216604), (3216649, 3216654), (3216843, 3216844), (3217068, 3217069), (3217154, 3217155), (3217243, 3217244), (3217286, 3217288), (3217609, 3217610), (3217615, 3217616), (3217621, 3217622), (3217650, 3217652), (3217696, 3217697), (3217740, 3217741), (3217762, 3217764), (3217803, 3217804), (3217835, 3217836), (3217838, 3217848), (3217861, 3217862)]
kernel_rfl DEC_clearFill.st1.fh95 : DEC_clearFill.st1.s96.heap = setAll DEC_clearFill.st1.s95.heap (rangesOf DEC_clearFill.st1.s96.heap DEC_clearFill.st1.fR95 ++ freshOf DEC_clearFill.st1.s96.heap DEC_clearFill.st1.s95.next DEC_clearFill.st1.s96.next)
kernel_rfl DEC_clearFill.st1.fb95 : footRB DEC_clearFill.st1.s95 DEC_clearFill.st1.s96 DEC_clearFill.st1.fR95 = true
kernel_rfl DEC_clearFill.st1.fc95 : (Nat.ble DEC_clearFill.st1.s0.next DEC_clearFill.st1.s95.next && Nat.ble DEC_clearFill.st1.s96.next DEC_clearFill.st1.s150.next && coverB DEC_clearFill.st1.fR95 DEC_clearFill.st1.wrR DEC_clearFill.st1.s0.next) = true
theorem DEC_clearFill.st1.fa96 : FootAcc DEC_clearFill.st1.wr DEC_clearFill.st1.s150 DEC_clearFill.st1.s0 DEC_clearFill.st1.s96 :=
  DEC_clearFill.st1.fa95.step (stageFoot_ofRF DEC_clearFill.st1.fh95 DEC_clearFill.st1.fb95) (incl_of_footW DEC_clearFill.st1.fb95 DEC_clearFill.st1.fc95)

end Host.Load.Run.Tpl

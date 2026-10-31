import host.sim.template.a4dec_clearGrow.st1.FootS1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearGrow.st1.fR64 : List (Nat × Nat) := [(3123796, 3123797), (3185011, 3185012), (3185077, 3185078), (3186691, 3186692), (3186745, 3186746), (3186751, 3186752), (3186757, 3186758), (3187011, 3187012), (3187032, 3187033), (3187082, 3187083), (3187100, 3187102), (3187134, 3187135), (3187137, 3187147)]
kernel_rfl DEC_clearGrow.st1.fh64 : DEC_clearGrow.st1.s65.heap = setAll DEC_clearGrow.st1.s64.heap (rangesOf DEC_clearGrow.st1.s65.heap DEC_clearGrow.st1.fR64 ++ freshOf DEC_clearGrow.st1.s65.heap DEC_clearGrow.st1.s64.next DEC_clearGrow.st1.s65.next)
kernel_rfl DEC_clearGrow.st1.fb64 : footRB DEC_clearGrow.st1.s64 DEC_clearGrow.st1.s65 DEC_clearGrow.st1.fR64 = true
kernel_rfl DEC_clearGrow.st1.fc64 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s64.next && Nat.ble DEC_clearGrow.st1.s65.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR64 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa65 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s65 :=
  DEC_clearGrow.st1.fa64.step (stageFoot_ofRF DEC_clearGrow.st1.fh64 DEC_clearGrow.st1.fb64) (incl_of_footW DEC_clearGrow.st1.fb64 DEC_clearGrow.st1.fc64)

def DEC_clearGrow.st1.fR65 : List (Nat × Nat) := [(4841, 4842), (2672508, 2672509), (3039368, 3039369), (3039420, 3039421), (3187442, 3187445), (3187505, 3187515), (3187831, 3187832), (3188006, 3188007), (3188074, 3188075), (3188142, 3188143), (3188167, 3188169), (3188170, 3188171)]
kernel_rfl DEC_clearGrow.st1.fh65 : DEC_clearGrow.st1.s66.heap = setAll DEC_clearGrow.st1.s65.heap (rangesOf DEC_clearGrow.st1.s66.heap DEC_clearGrow.st1.fR65 ++ freshOf DEC_clearGrow.st1.s66.heap DEC_clearGrow.st1.s65.next DEC_clearGrow.st1.s66.next)
kernel_rfl DEC_clearGrow.st1.fb65 : footRB DEC_clearGrow.st1.s65 DEC_clearGrow.st1.s66 DEC_clearGrow.st1.fR65 = true
kernel_rfl DEC_clearGrow.st1.fc65 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s65.next && Nat.ble DEC_clearGrow.st1.s66.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR65 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa66 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s66 :=
  DEC_clearGrow.st1.fa65.step (stageFoot_ofRF DEC_clearGrow.st1.fh65 DEC_clearGrow.st1.fb65) (incl_of_footW DEC_clearGrow.st1.fb65 DEC_clearGrow.st1.fc65)

def DEC_clearGrow.st1.fR66 : List (Nat × Nat) := [(3123796, 3123797), (3187403, 3187404), (3187470, 3187471), (3189059, 3189060), (3189117, 3189118), (3189123, 3189124), (3189129, 3189130), (3189137, 3189138), (3189148, 3189152)]
kernel_rfl DEC_clearGrow.st1.fh66 : DEC_clearGrow.st1.s67.heap = setAll DEC_clearGrow.st1.s66.heap (rangesOf DEC_clearGrow.st1.s67.heap DEC_clearGrow.st1.fR66 ++ freshOf DEC_clearGrow.st1.s67.heap DEC_clearGrow.st1.s66.next DEC_clearGrow.st1.s67.next)
kernel_rfl DEC_clearGrow.st1.fb66 : footRB DEC_clearGrow.st1.s66 DEC_clearGrow.st1.s67 DEC_clearGrow.st1.fR66 = true
kernel_rfl DEC_clearGrow.st1.fc66 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s66.next && Nat.ble DEC_clearGrow.st1.s67.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR66 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa67 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s67 :=
  DEC_clearGrow.st1.fa66.step (stageFoot_ofRF DEC_clearGrow.st1.fh66 DEC_clearGrow.st1.fb66) (incl_of_footW DEC_clearGrow.st1.fb66 DEC_clearGrow.st1.fc66)

def DEC_clearGrow.st1.fR67 : List (Nat × Nat) := [(2672517, 2672518), (3041474, 3041475), (3189879, 3189883), (3190108, 3190109), (3190174, 3190176)]
kernel_rfl DEC_clearGrow.st1.fh67 : DEC_clearGrow.st1.s68.heap = setAll DEC_clearGrow.st1.s67.heap (rangesOf DEC_clearGrow.st1.s68.heap DEC_clearGrow.st1.fR67 ++ freshOf DEC_clearGrow.st1.s68.heap DEC_clearGrow.st1.s67.next DEC_clearGrow.st1.s68.next)
kernel_rfl DEC_clearGrow.st1.fb67 : footRB DEC_clearGrow.st1.s67 DEC_clearGrow.st1.s68 DEC_clearGrow.st1.fR67 = true
kernel_rfl DEC_clearGrow.st1.fc67 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s67.next && Nat.ble DEC_clearGrow.st1.s68.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR67 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa68 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s68 :=
  DEC_clearGrow.st1.fa67.step (stageFoot_ofRF DEC_clearGrow.st1.fh67 DEC_clearGrow.st1.fb67) (incl_of_footW DEC_clearGrow.st1.fb67 DEC_clearGrow.st1.fc67)

def DEC_clearGrow.st1.fR68 : List (Nat × Nat) := [(2672517, 2672518), (3041903, 3041904), (3189835, 3189838), (3189883, 3189888), (3190077, 3190078), (3190302, 3190303), (3190388, 3190389), (3190477, 3190478), (3190520, 3190522), (3190843, 3190844), (3190849, 3190850), (3190855, 3190856), (3190974, 3190975), (3191175, 3191176)]
kernel_rfl DEC_clearGrow.st1.fh68 : DEC_clearGrow.st1.s69.heap = setAll DEC_clearGrow.st1.s68.heap (rangesOf DEC_clearGrow.st1.s69.heap DEC_clearGrow.st1.fR68 ++ freshOf DEC_clearGrow.st1.s69.heap DEC_clearGrow.st1.s68.next DEC_clearGrow.st1.s69.next)
kernel_rfl DEC_clearGrow.st1.fb68 : footRB DEC_clearGrow.st1.s68 DEC_clearGrow.st1.s69 DEC_clearGrow.st1.fR68 = true
kernel_rfl DEC_clearGrow.st1.fc68 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s68.next && Nat.ble DEC_clearGrow.st1.s69.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR68 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa69 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s69 :=
  DEC_clearGrow.st1.fa68.step (stageFoot_ofRF DEC_clearGrow.st1.fh68 DEC_clearGrow.st1.fb68) (incl_of_footW DEC_clearGrow.st1.fb68 DEC_clearGrow.st1.fc68)

def DEC_clearGrow.st1.fR69 : List (Nat × Nat) := [(3123796, 3123797), (3189775, 3189776), (3189863, 3189864), (3191477, 3191478), (3191531, 3191532), (3191537, 3191538), (3191543, 3191544), (3191797, 3191798), (3191818, 3191819), (3191868, 3191869), (3191887, 3191888), (3192030, 3192031), (3192108, 3192109)]
kernel_rfl DEC_clearGrow.st1.fh69 : DEC_clearGrow.st1.s70.heap = setAll DEC_clearGrow.st1.s69.heap (rangesOf DEC_clearGrow.st1.s70.heap DEC_clearGrow.st1.fR69 ++ freshOf DEC_clearGrow.st1.s70.heap DEC_clearGrow.st1.s69.next DEC_clearGrow.st1.s70.next)
kernel_rfl DEC_clearGrow.st1.fb69 : footRB DEC_clearGrow.st1.s69 DEC_clearGrow.st1.s70 DEC_clearGrow.st1.fR69 = true
kernel_rfl DEC_clearGrow.st1.fc69 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s69.next && Nat.ble DEC_clearGrow.st1.s70.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR69 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa70 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s70 :=
  DEC_clearGrow.st1.fa69.step (stageFoot_ofRF DEC_clearGrow.st1.fh69 DEC_clearGrow.st1.fb69) (incl_of_footW DEC_clearGrow.st1.fb69 DEC_clearGrow.st1.fc69)

def DEC_clearGrow.st1.fR70 : List (Nat × Nat) := [(2672522, 2672523), (3043866, 3043867), (3044295, 3044296), (3192227, 3192230), (3192275, 3192280), (3192469, 3192470), (3192694, 3192695), (3192780, 3192781), (3192869, 3192870), (3192907, 3192914), (3192954, 3192955), (3193007, 3193008), (3193178, 3193179)]
kernel_rfl DEC_clearGrow.st1.fh70 : DEC_clearGrow.st1.s71.heap = setAll DEC_clearGrow.st1.s70.heap (rangesOf DEC_clearGrow.st1.s71.heap DEC_clearGrow.st1.fR70 ++ freshOf DEC_clearGrow.st1.s71.heap DEC_clearGrow.st1.s70.next DEC_clearGrow.st1.s71.next)
kernel_rfl DEC_clearGrow.st1.fb70 : footRB DEC_clearGrow.st1.s70 DEC_clearGrow.st1.s71 DEC_clearGrow.st1.fR70 = true
kernel_rfl DEC_clearGrow.st1.fc70 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s70.next && Nat.ble DEC_clearGrow.st1.s71.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR70 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa71 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s71 :=
  DEC_clearGrow.st1.fa70.step (stageFoot_ofRF DEC_clearGrow.st1.fh70 DEC_clearGrow.st1.fb70) (incl_of_footW DEC_clearGrow.st1.fb70 DEC_clearGrow.st1.fc70)

def DEC_clearGrow.st1.fR71 : List (Nat × Nat) := [(3123796, 3123797), (3192189, 3192190), (3192255, 3192256), (3193869, 3193870), (3193923, 3193924), (3193929, 3193930), (3193935, 3193936), (3193943, 3193944), (3193956, 3193958), (3194012, 3194013), (3194040, 3194041), (3194043, 3194053)]
kernel_rfl DEC_clearGrow.st1.fh71 : DEC_clearGrow.st1.s72.heap = setAll DEC_clearGrow.st1.s71.heap (rangesOf DEC_clearGrow.st1.s72.heap DEC_clearGrow.st1.fR71 ++ freshOf DEC_clearGrow.st1.s72.heap DEC_clearGrow.st1.s71.next DEC_clearGrow.st1.s72.next)
kernel_rfl DEC_clearGrow.st1.fb71 : footRB DEC_clearGrow.st1.s71 DEC_clearGrow.st1.s72 DEC_clearGrow.st1.fR71 = true
kernel_rfl DEC_clearGrow.st1.fc71 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s71.next && Nat.ble DEC_clearGrow.st1.s72.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR71 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa72 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s72 :=
  DEC_clearGrow.st1.fa71.step (stageFoot_ofRF DEC_clearGrow.st1.fh71 DEC_clearGrow.st1.fb71) (incl_of_footW DEC_clearGrow.st1.fb71 DEC_clearGrow.st1.fc71)

def DEC_clearGrow.st1.fR72 : List (Nat × Nat) := [(2672527, 2672528), (3046262, 3046263), (3046691, 3046692), (3194667, 3194674), (3194865, 3194866), (3195054, 3195055), (3195080, 3195084)]
kernel_rfl DEC_clearGrow.st1.fh72 : DEC_clearGrow.st1.s73.heap = setAll DEC_clearGrow.st1.s72.heap (rangesOf DEC_clearGrow.st1.s73.heap DEC_clearGrow.st1.fR72 ++ freshOf DEC_clearGrow.st1.s73.heap DEC_clearGrow.st1.s72.next DEC_clearGrow.st1.s73.next)
kernel_rfl DEC_clearGrow.st1.fb72 : footRB DEC_clearGrow.st1.s72 DEC_clearGrow.st1.s73 DEC_clearGrow.st1.fR72 = true
kernel_rfl DEC_clearGrow.st1.fc72 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s72.next && Nat.ble DEC_clearGrow.st1.s73.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR72 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa73 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s73 :=
  DEC_clearGrow.st1.fa72.step (stageFoot_ofRF DEC_clearGrow.st1.fh72 DEC_clearGrow.st1.fb72) (incl_of_footW DEC_clearGrow.st1.fb72 DEC_clearGrow.st1.fc72)

def DEC_clearGrow.st1.fR73 : List (Nat × Nat) := [(3123796, 3123797), (3194585, 3194586), (3194623, 3194626), (3194651, 3194652), (3194674, 3194676), (3196049, 3196050), (3196082, 3196083)]
kernel_rfl DEC_clearGrow.st1.fh73 : DEC_clearGrow.st1.s74.heap = setAll DEC_clearGrow.st1.s73.heap (rangesOf DEC_clearGrow.st1.s74.heap DEC_clearGrow.st1.fR73 ++ freshOf DEC_clearGrow.st1.s74.heap DEC_clearGrow.st1.s73.next DEC_clearGrow.st1.s74.next)
kernel_rfl DEC_clearGrow.st1.fb73 : footRB DEC_clearGrow.st1.s73 DEC_clearGrow.st1.s74 DEC_clearGrow.st1.fR73 = true
kernel_rfl DEC_clearGrow.st1.fc73 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s73.next && Nat.ble DEC_clearGrow.st1.s74.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR73 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa74 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s74 :=
  DEC_clearGrow.st1.fa73.step (stageFoot_ofRF DEC_clearGrow.st1.fh73 DEC_clearGrow.st1.fb73) (incl_of_footW DEC_clearGrow.st1.fb73 DEC_clearGrow.st1.fc73)

def DEC_clearGrow.st1.fR74 : List (Nat × Nat) := [(4841, 4842), (2672539, 2672540), (3197015, 3197016), (3197032, 3197036)]
kernel_rfl DEC_clearGrow.st1.fh74 : DEC_clearGrow.st1.s75.heap = setAll DEC_clearGrow.st1.s74.heap (rangesOf DEC_clearGrow.st1.s75.heap DEC_clearGrow.st1.fR74 ++ freshOf DEC_clearGrow.st1.s75.heap DEC_clearGrow.st1.s74.next DEC_clearGrow.st1.s75.next)
kernel_rfl DEC_clearGrow.st1.fb74 : footRB DEC_clearGrow.st1.s74 DEC_clearGrow.st1.s75 DEC_clearGrow.st1.fR74 = true
kernel_rfl DEC_clearGrow.st1.fc74 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s74.next && Nat.ble DEC_clearGrow.st1.s75.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR74 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa75 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s75 :=
  DEC_clearGrow.st1.fa74.step (stageFoot_ofRF DEC_clearGrow.st1.fh74 DEC_clearGrow.st1.fb74) (incl_of_footW DEC_clearGrow.st1.fb74 DEC_clearGrow.st1.fc74)

def DEC_clearGrow.st1.fR75 : List (Nat × Nat) := [(2672539, 2672540), (3048746, 3048747), (3048798, 3048799), (3197016, 3197019), (3197082, 3197089), (3197405, 3197406), (3197815, 3197816), (3197850, 3197851), (3197885, 3197886), (3197910, 3197912), (3197918, 3197925), (3198009, 3198010), (3198039, 3198040), (3198085, 3198086), (3198096, 3198097)]
kernel_rfl DEC_clearGrow.st1.fh75 : DEC_clearGrow.st1.s76.heap = setAll DEC_clearGrow.st1.s75.heap (rangesOf DEC_clearGrow.st1.s76.heap DEC_clearGrow.st1.fR75 ++ freshOf DEC_clearGrow.st1.s76.heap DEC_clearGrow.st1.s75.next DEC_clearGrow.st1.s76.next)
kernel_rfl DEC_clearGrow.st1.fb75 : footRB DEC_clearGrow.st1.s75 DEC_clearGrow.st1.s76 DEC_clearGrow.st1.fR75 = true
kernel_rfl DEC_clearGrow.st1.fc75 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s75.next && Nat.ble DEC_clearGrow.st1.s76.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR75 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa76 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s76 :=
  DEC_clearGrow.st1.fa75.step (stageFoot_ofRF DEC_clearGrow.st1.fh75 DEC_clearGrow.st1.fb75) (incl_of_footW DEC_clearGrow.st1.fb75 DEC_clearGrow.st1.fc75)

def DEC_clearGrow.st1.fR76 : List (Nat × Nat) := [(3123796, 3123797), (3196977, 3196978), (3197044, 3197045), (3198633, 3198634), (3198691, 3198692), (3198697, 3198698), (3198703, 3198704), (3198957, 3198958), (3198978, 3198979), (3199028, 3199029), (3199050, 3199052), (3199084, 3199085), (3199086, 3199097)]
kernel_rfl DEC_clearGrow.st1.fh76 : DEC_clearGrow.st1.s77.heap = setAll DEC_clearGrow.st1.s76.heap (rangesOf DEC_clearGrow.st1.s77.heap DEC_clearGrow.st1.fR76 ++ freshOf DEC_clearGrow.st1.s77.heap DEC_clearGrow.st1.s76.next DEC_clearGrow.st1.s77.next)
kernel_rfl DEC_clearGrow.st1.fb76 : footRB DEC_clearGrow.st1.s76 DEC_clearGrow.st1.s77 DEC_clearGrow.st1.fR76 = true
kernel_rfl DEC_clearGrow.st1.fc76 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s76.next && Nat.ble DEC_clearGrow.st1.s77.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR76 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa77 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s77 :=
  DEC_clearGrow.st1.fa76.step (stageFoot_ofRF DEC_clearGrow.st1.fh76 DEC_clearGrow.st1.fb76) (incl_of_footW DEC_clearGrow.st1.fb76 DEC_clearGrow.st1.fc76)

def DEC_clearGrow.st1.fR77 : List (Nat × Nat) := [(2672548, 2672549), (3050856, 3050857), (3051285, 3051286), (3199461, 3199465), (3199655, 3199656), (3199880, 3199881), (3199966, 3199967), (3200055, 3200056)]
kernel_rfl DEC_clearGrow.st1.fh77 : DEC_clearGrow.st1.s78.heap = setAll DEC_clearGrow.st1.s77.heap (rangesOf DEC_clearGrow.st1.s78.heap DEC_clearGrow.st1.fR77 ++ freshOf DEC_clearGrow.st1.s78.heap DEC_clearGrow.st1.s77.next DEC_clearGrow.st1.s78.next)
kernel_rfl DEC_clearGrow.st1.fb77 : footRB DEC_clearGrow.st1.s77 DEC_clearGrow.st1.s78 DEC_clearGrow.st1.fR77 = true
kernel_rfl DEC_clearGrow.st1.fc77 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s77.next && Nat.ble DEC_clearGrow.st1.s78.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR77 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa78 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s78 :=
  DEC_clearGrow.st1.fa77.step (stageFoot_ofRF DEC_clearGrow.st1.fh77 DEC_clearGrow.st1.fb77) (incl_of_footW DEC_clearGrow.st1.fb77 DEC_clearGrow.st1.fc77)

def DEC_clearGrow.st1.fR78 : List (Nat × Nat) := [(3123796, 3123797), (3199353, 3199354), (3199413, 3199416), (3199441, 3199442), (3199465, 3199466), (3200872, 3200873), (3201055, 3201056), (3201063, 3201065)]
kernel_rfl DEC_clearGrow.st1.fh78 : DEC_clearGrow.st1.s79.heap = setAll DEC_clearGrow.st1.s78.heap (rangesOf DEC_clearGrow.st1.s79.heap DEC_clearGrow.st1.fR78 ++ freshOf DEC_clearGrow.st1.s79.heap DEC_clearGrow.st1.s78.next DEC_clearGrow.st1.s79.next)
kernel_rfl DEC_clearGrow.st1.fb78 : footRB DEC_clearGrow.st1.s78 DEC_clearGrow.st1.s79 DEC_clearGrow.st1.fR78 = true
kernel_rfl DEC_clearGrow.st1.fc78 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s78.next && Nat.ble DEC_clearGrow.st1.s79.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR78 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa79 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s79 :=
  DEC_clearGrow.st1.fa78.step (stageFoot_ofRF DEC_clearGrow.st1.fh78 DEC_clearGrow.st1.fb78) (incl_of_footW DEC_clearGrow.st1.fb78 DEC_clearGrow.st1.fc78)

def DEC_clearGrow.st1.fR79 : List (Nat × Nat) := [(2672553, 2672554), (3053252, 3053253), (3201852, 3201857), (3201893, 3201894), (3201961, 3201962), (3201966, 3201974)]
kernel_rfl DEC_clearGrow.st1.fh79 : DEC_clearGrow.st1.s80.heap = setAll DEC_clearGrow.st1.s79.heap (rangesOf DEC_clearGrow.st1.s80.heap DEC_clearGrow.st1.fR79 ++ freshOf DEC_clearGrow.st1.s80.heap DEC_clearGrow.st1.s79.next DEC_clearGrow.st1.s80.next)
kernel_rfl DEC_clearGrow.st1.fb79 : footRB DEC_clearGrow.st1.s79 DEC_clearGrow.st1.s80 DEC_clearGrow.st1.fR79 = true
kernel_rfl DEC_clearGrow.st1.fc79 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s79.next && Nat.ble DEC_clearGrow.st1.s80.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR79 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa80 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s80 :=
  DEC_clearGrow.st1.fa79.step (stageFoot_ofRF DEC_clearGrow.st1.fh79 DEC_clearGrow.st1.fb79) (incl_of_footW DEC_clearGrow.st1.fb79 DEC_clearGrow.st1.fc79)

def DEC_clearGrow.st1.fR80 : List (Nat × Nat) := [(2672553, 2672554), (3053681, 3053682), (3201809, 3201812), (3201857, 3201862), (3202051, 3202052), (3202276, 3202277), (3202362, 3202363), (3202451, 3202452), (3202494, 3202496), (3202817, 3202818), (3202823, 3202824), (3202829, 3202830), (3202858, 3202860), (3202904, 3202905), (3202948, 3202949), (3202970, 3202972), (3203011, 3203012), (3203043, 3203044), (3203046, 3203056), (3203099, 3203100)]
kernel_rfl DEC_clearGrow.st1.fh80 : DEC_clearGrow.st1.s81.heap = setAll DEC_clearGrow.st1.s80.heap (rangesOf DEC_clearGrow.st1.s81.heap DEC_clearGrow.st1.fR80 ++ freshOf DEC_clearGrow.st1.s81.heap DEC_clearGrow.st1.s80.next DEC_clearGrow.st1.s81.next)
kernel_rfl DEC_clearGrow.st1.fb80 : footRB DEC_clearGrow.st1.s80 DEC_clearGrow.st1.s81 DEC_clearGrow.st1.fR80 = true
kernel_rfl DEC_clearGrow.st1.fc80 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s80.next && Nat.ble DEC_clearGrow.st1.s81.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR80 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa81 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s81 :=
  DEC_clearGrow.st1.fa80.step (stageFoot_ofRF DEC_clearGrow.st1.fh80 DEC_clearGrow.st1.fb80) (incl_of_footW DEC_clearGrow.st1.fb80 DEC_clearGrow.st1.fc80)

def DEC_clearGrow.st1.fR81 : List (Nat × Nat) := [(3123796, 3123797), (3201771, 3201772), (3201837, 3201838), (3203451, 3203452), (3203505, 3203506), (3203511, 3203512), (3203517, 3203518), (3203771, 3203772), (3203792, 3203793), (3203842, 3203843), (3203864, 3203866), (3203905, 3203911), (3204001, 3204002)]
kernel_rfl DEC_clearGrow.st1.fh81 : DEC_clearGrow.st1.s82.heap = setAll DEC_clearGrow.st1.s81.heap (rangesOf DEC_clearGrow.st1.s82.heap DEC_clearGrow.st1.fR81 ++ freshOf DEC_clearGrow.st1.s82.heap DEC_clearGrow.st1.s81.next DEC_clearGrow.st1.s82.next)
kernel_rfl DEC_clearGrow.st1.fb81 : footRB DEC_clearGrow.st1.s81 DEC_clearGrow.st1.s82 DEC_clearGrow.st1.fR81 = true
kernel_rfl DEC_clearGrow.st1.fc81 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s81.next && Nat.ble DEC_clearGrow.st1.s82.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR81 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa82 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s82 :=
  DEC_clearGrow.st1.fa81.step (stageFoot_ofRF DEC_clearGrow.st1.fh81 DEC_clearGrow.st1.fb81) (incl_of_footW DEC_clearGrow.st1.fb81 DEC_clearGrow.st1.fc81)

def DEC_clearGrow.st1.fR82 : List (Nat × Nat) := [(2672558, 2672559), (3055648, 3055649), (3056077, 3056078), (3204205, 3204208), (3204253, 3204258), (3204447, 3204448), (3204672, 3204673), (3204758, 3204759), (3204847, 3204848), (3204885, 3204892), (3204931, 3204933), (3204985, 3204986), (3205010, 3205011), (3205033, 3205034), (3205044, 3205045)]
kernel_rfl DEC_clearGrow.st1.fh82 : DEC_clearGrow.st1.s83.heap = setAll DEC_clearGrow.st1.s82.heap (rangesOf DEC_clearGrow.st1.s83.heap DEC_clearGrow.st1.fR82 ++ freshOf DEC_clearGrow.st1.s83.heap DEC_clearGrow.st1.s82.next DEC_clearGrow.st1.s83.next)
kernel_rfl DEC_clearGrow.st1.fb82 : footRB DEC_clearGrow.st1.s82 DEC_clearGrow.st1.s83 DEC_clearGrow.st1.fR82 = true
kernel_rfl DEC_clearGrow.st1.fc82 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s82.next && Nat.ble DEC_clearGrow.st1.s83.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR82 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa83 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s83 :=
  DEC_clearGrow.st1.fa82.step (stageFoot_ofRF DEC_clearGrow.st1.fh82 DEC_clearGrow.st1.fb82) (incl_of_footW DEC_clearGrow.st1.fb82 DEC_clearGrow.st1.fc82)

def DEC_clearGrow.st1.fR83 : List (Nat × Nat) := [(3123796, 3123797), (3204167, 3204168), (3204233, 3204234), (3205847, 3205848), (3205901, 3205902), (3205907, 3205908), (3205913, 3205914), (3205921, 3205922), (3205933, 3205936), (3205980, 3205984)]
kernel_rfl DEC_clearGrow.st1.fh83 : DEC_clearGrow.st1.s84.heap = setAll DEC_clearGrow.st1.s83.heap (rangesOf DEC_clearGrow.st1.s84.heap DEC_clearGrow.st1.fR83 ++ freshOf DEC_clearGrow.st1.s84.heap DEC_clearGrow.st1.s83.next DEC_clearGrow.st1.s84.next)
kernel_rfl DEC_clearGrow.st1.fb83 : footRB DEC_clearGrow.st1.s83 DEC_clearGrow.st1.s84 DEC_clearGrow.st1.fR83 = true
kernel_rfl DEC_clearGrow.st1.fc83 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s83.next && Nat.ble DEC_clearGrow.st1.s84.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR83 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa84 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s84 :=
  DEC_clearGrow.st1.fa83.step (stageFoot_ofRF DEC_clearGrow.st1.fh83 DEC_clearGrow.st1.fb83) (incl_of_footW DEC_clearGrow.st1.fb83 DEC_clearGrow.st1.fc83)

def DEC_clearGrow.st1.fR84 : List (Nat × Nat) := [(4841, 4842), (2672570, 2672571), (3058132, 3058133), (3058184, 3058185), (3206658, 3206666), (3206797, 3206798), (3206892, 3206893), (3206956, 3206957)]
kernel_rfl DEC_clearGrow.st1.fh84 : DEC_clearGrow.st1.s85.heap = setAll DEC_clearGrow.st1.s84.heap (rangesOf DEC_clearGrow.st1.s85.heap DEC_clearGrow.st1.fR84 ++ freshOf DEC_clearGrow.st1.s85.heap DEC_clearGrow.st1.s84.next DEC_clearGrow.st1.s85.next)
kernel_rfl DEC_clearGrow.st1.fb84 : footRB DEC_clearGrow.st1.s84 DEC_clearGrow.st1.s85 DEC_clearGrow.st1.fR84 = true
kernel_rfl DEC_clearGrow.st1.fc84 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s84.next && Nat.ble DEC_clearGrow.st1.s85.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR84 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa85 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s85 :=
  DEC_clearGrow.st1.fa84.step (stageFoot_ofRF DEC_clearGrow.st1.fh84 DEC_clearGrow.st1.fb84) (incl_of_footW DEC_clearGrow.st1.fb84 DEC_clearGrow.st1.fc84)

def DEC_clearGrow.st1.fR85 : List (Nat × Nat) := [(3206598, 3206601), (3206626, 3206627), (3206665, 3206671), (3206987, 3206988), (3207432, 3207433), (3207907, 3207908), (3207956, 3207957), (3208005, 3208006)]
kernel_rfl DEC_clearGrow.st1.fh85 : DEC_clearGrow.st1.s86.heap = setAll DEC_clearGrow.st1.s85.heap (rangesOf DEC_clearGrow.st1.s86.heap DEC_clearGrow.st1.fR85 ++ freshOf DEC_clearGrow.st1.s86.heap DEC_clearGrow.st1.s85.next DEC_clearGrow.st1.s86.next)
kernel_rfl DEC_clearGrow.st1.fb85 : footRB DEC_clearGrow.st1.s85 DEC_clearGrow.st1.s86 DEC_clearGrow.st1.fR85 = true
kernel_rfl DEC_clearGrow.st1.fc85 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s85.next && Nat.ble DEC_clearGrow.st1.s86.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR85 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa86 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s86 :=
  DEC_clearGrow.st1.fa85.step (stageFoot_ofRF DEC_clearGrow.st1.fh85 DEC_clearGrow.st1.fb85) (incl_of_footW DEC_clearGrow.st1.fb85 DEC_clearGrow.st1.fc85)

def DEC_clearGrow.st1.fR86 : List (Nat × Nat) := [(2672579, 2672580), (3060238, 3060239), (3123796, 3123797), (3206559, 3206560)]
kernel_rfl DEC_clearGrow.st1.fh86 : DEC_clearGrow.st1.s87.heap = setAll DEC_clearGrow.st1.s86.heap (rangesOf DEC_clearGrow.st1.s87.heap DEC_clearGrow.st1.fR86 ++ freshOf DEC_clearGrow.st1.s87.heap DEC_clearGrow.st1.s86.next DEC_clearGrow.st1.s87.next)
kernel_rfl DEC_clearGrow.st1.fb86 : footRB DEC_clearGrow.st1.s86 DEC_clearGrow.st1.s87 DEC_clearGrow.st1.fR86 = true
kernel_rfl DEC_clearGrow.st1.fc86 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s86.next && Nat.ble DEC_clearGrow.st1.s87.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR86 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa87 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s87 :=
  DEC_clearGrow.st1.fa86.step (stageFoot_ofRF DEC_clearGrow.st1.fh86 DEC_clearGrow.st1.fb86) (incl_of_footW DEC_clearGrow.st1.fb86 DEC_clearGrow.st1.fc86)

def DEC_clearGrow.st1.fR87 : List (Nat × Nat) := [(2672579, 2672580), (3060667, 3060668), (3208991, 3208994), (3209039, 3209044), (3209233, 3209234), (3209458, 3209459), (3209544, 3209545), (3209633, 3209634), (3209673, 3209678), (3209942, 3209943), (3209957, 3209959), (3209999, 3210000), (3210005, 3210006), (3210011, 3210012)]
kernel_rfl DEC_clearGrow.st1.fh87 : DEC_clearGrow.st1.s88.heap = setAll DEC_clearGrow.st1.s87.heap (rangesOf DEC_clearGrow.st1.s88.heap DEC_clearGrow.st1.fR87 ++ freshOf DEC_clearGrow.st1.s88.heap DEC_clearGrow.st1.s87.next DEC_clearGrow.st1.s88.next)
kernel_rfl DEC_clearGrow.st1.fb87 : footRB DEC_clearGrow.st1.s87 DEC_clearGrow.st1.s88 DEC_clearGrow.st1.fR87 = true
kernel_rfl DEC_clearGrow.st1.fc87 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s87.next && Nat.ble DEC_clearGrow.st1.s88.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR87 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa88 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s88 :=
  DEC_clearGrow.st1.fa87.step (stageFoot_ofRF DEC_clearGrow.st1.fh87 DEC_clearGrow.st1.fb87) (incl_of_footW DEC_clearGrow.st1.fb87 DEC_clearGrow.st1.fc87)

def DEC_clearGrow.st1.fR88 : List (Nat × Nat) := [(3123796, 3123797), (3208931, 3208932), (3209019, 3209020), (3210633, 3210634), (3210687, 3210688), (3210693, 3210694), (3210699, 3210700), (3210707, 3210708), (3210721, 3210722), (3210922, 3210923), (3210945, 3210947), (3210948, 3210949)]
kernel_rfl DEC_clearGrow.st1.fh88 : DEC_clearGrow.st1.s89.heap = setAll DEC_clearGrow.st1.s88.heap (rangesOf DEC_clearGrow.st1.s89.heap DEC_clearGrow.st1.fR88 ++ freshOf DEC_clearGrow.st1.s89.heap DEC_clearGrow.st1.s88.next DEC_clearGrow.st1.s89.next)
kernel_rfl DEC_clearGrow.st1.fb88 : footRB DEC_clearGrow.st1.s88 DEC_clearGrow.st1.s89 DEC_clearGrow.st1.fR88 = true
kernel_rfl DEC_clearGrow.st1.fc88 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s88.next && Nat.ble DEC_clearGrow.st1.s89.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR88 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa89 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s89 :=
  DEC_clearGrow.st1.fa88.step (stageFoot_ofRF DEC_clearGrow.st1.fh88 DEC_clearGrow.st1.fb88) (incl_of_footW DEC_clearGrow.st1.fb88 DEC_clearGrow.st1.fc88)

def DEC_clearGrow.st1.fR89 : List (Nat × Nat) := [(2672584, 2672585), (3062630, 3062631), (3063059, 3063060), (3211428, 3211435), (3211625, 3211626), (3211850, 3211851), (3211863, 3211864), (3211936, 3211937)]
kernel_rfl DEC_clearGrow.st1.fh89 : DEC_clearGrow.st1.s90.heap = setAll DEC_clearGrow.st1.s89.heap (rangesOf DEC_clearGrow.st1.s90.heap DEC_clearGrow.st1.fR89 ++ freshOf DEC_clearGrow.st1.s90.heap DEC_clearGrow.st1.s89.next DEC_clearGrow.st1.s90.next)
kernel_rfl DEC_clearGrow.st1.fb89 : footRB DEC_clearGrow.st1.s89 DEC_clearGrow.st1.s90 DEC_clearGrow.st1.fR89 = true
kernel_rfl DEC_clearGrow.st1.fc89 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s89.next && Nat.ble DEC_clearGrow.st1.s90.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR89 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa90 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s90 :=
  DEC_clearGrow.st1.fa89.step (stageFoot_ofRF DEC_clearGrow.st1.fh89 DEC_clearGrow.st1.fb89) (incl_of_footW DEC_clearGrow.st1.fb89 DEC_clearGrow.st1.fc89)

def DEC_clearGrow.st1.fR90 : List (Nat × Nat) := [(3123796, 3123797), (3211345, 3211346), (3211383, 3211386), (3211411, 3211412), (3211435, 3211436), (3212842, 3212843), (3212867, 3212868), (3212935, 3212936), (3212938, 3212948)]
kernel_rfl DEC_clearGrow.st1.fh90 : DEC_clearGrow.st1.s91.heap = setAll DEC_clearGrow.st1.s90.heap (rangesOf DEC_clearGrow.st1.s91.heap DEC_clearGrow.st1.fR90 ++ freshOf DEC_clearGrow.st1.s91.heap DEC_clearGrow.st1.s90.next DEC_clearGrow.st1.s91.next)
kernel_rfl DEC_clearGrow.st1.fb90 : footRB DEC_clearGrow.st1.s90 DEC_clearGrow.st1.s91 DEC_clearGrow.st1.fR90 = true
kernel_rfl DEC_clearGrow.st1.fc90 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s90.next && Nat.ble DEC_clearGrow.st1.s91.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR90 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa91 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s91 :=
  DEC_clearGrow.st1.fa90.step (stageFoot_ofRF DEC_clearGrow.st1.fh90 DEC_clearGrow.st1.fb90) (incl_of_footW DEC_clearGrow.st1.fb90 DEC_clearGrow.st1.fc90)

def DEC_clearGrow.st1.fR91 : List (Nat × Nat) := [(2672589, 2672590), (3065022, 3065023), (3213818, 3213823), (3213859, 3213860), (3213891, 3213892)]
kernel_rfl DEC_clearGrow.st1.fh91 : DEC_clearGrow.st1.s92.heap = setAll DEC_clearGrow.st1.s91.heap (rangesOf DEC_clearGrow.st1.s92.heap DEC_clearGrow.st1.fR91 ++ freshOf DEC_clearGrow.st1.s92.heap DEC_clearGrow.st1.s91.next DEC_clearGrow.st1.s92.next)
kernel_rfl DEC_clearGrow.st1.fb91 : footRB DEC_clearGrow.st1.s91 DEC_clearGrow.st1.s92 DEC_clearGrow.st1.fR91 = true
kernel_rfl DEC_clearGrow.st1.fc91 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s91.next && Nat.ble DEC_clearGrow.st1.s92.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR91 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa92 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s92 :=
  DEC_clearGrow.st1.fa91.step (stageFoot_ofRF DEC_clearGrow.st1.fh91 DEC_clearGrow.st1.fb91) (incl_of_footW DEC_clearGrow.st1.fb91 DEC_clearGrow.st1.fc91)

def DEC_clearGrow.st1.fR92 : List (Nat × Nat) := [(2672589, 2672590), (3065451, 3065452), (3213775, 3213778), (3213823, 3213828), (3214017, 3214018), (3214242, 3214243), (3214328, 3214329), (3214417, 3214418), (3214460, 3214462), (3214783, 3214784), (3214789, 3214790), (3214795, 3214796), (3214824, 3214826), (3214870, 3214871), (3214914, 3214915), (3214932, 3214938)]
kernel_rfl DEC_clearGrow.st1.fh92 : DEC_clearGrow.st1.s93.heap = setAll DEC_clearGrow.st1.s92.heap (rangesOf DEC_clearGrow.st1.s93.heap DEC_clearGrow.st1.fR92 ++ freshOf DEC_clearGrow.st1.s93.heap DEC_clearGrow.st1.s92.next DEC_clearGrow.st1.s93.next)
kernel_rfl DEC_clearGrow.st1.fb92 : footRB DEC_clearGrow.st1.s92 DEC_clearGrow.st1.s93 DEC_clearGrow.st1.fR92 = true
kernel_rfl DEC_clearGrow.st1.fc92 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s92.next && Nat.ble DEC_clearGrow.st1.s93.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR92 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa93 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s93 :=
  DEC_clearGrow.st1.fa92.step (stageFoot_ofRF DEC_clearGrow.st1.fh92 DEC_clearGrow.st1.fb92) (incl_of_footW DEC_clearGrow.st1.fb92 DEC_clearGrow.st1.fc92)

def DEC_clearGrow.st1.fR93 : List (Nat × Nat) := [(3123796, 3123797), (3213737, 3213738), (3213803, 3213804), (3215417, 3215418), (3215471, 3215472), (3215477, 3215478), (3215483, 3215484), (3215737, 3215738), (3215758, 3215759), (3215808, 3215809), (3215826, 3215828), (3215860, 3215861), (3215863, 3215873)]
kernel_rfl DEC_clearGrow.st1.fh93 : DEC_clearGrow.st1.s94.heap = setAll DEC_clearGrow.st1.s93.heap (rangesOf DEC_clearGrow.st1.s94.heap DEC_clearGrow.st1.fR93 ++ freshOf DEC_clearGrow.st1.s94.heap DEC_clearGrow.st1.s93.next DEC_clearGrow.st1.s94.next)
kernel_rfl DEC_clearGrow.st1.fb93 : footRB DEC_clearGrow.st1.s93 DEC_clearGrow.st1.s94 DEC_clearGrow.st1.fR93 = true
kernel_rfl DEC_clearGrow.st1.fc93 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s93.next && Nat.ble DEC_clearGrow.st1.s94.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR93 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa94 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s94 :=
  DEC_clearGrow.st1.fa93.step (stageFoot_ofRF DEC_clearGrow.st1.fh93 DEC_clearGrow.st1.fb93) (incl_of_footW DEC_clearGrow.st1.fb93 DEC_clearGrow.st1.fc93)

def DEC_clearGrow.st1.fR94 : List (Nat × Nat) := [(4841, 4842), (2672601, 2672602), (3067506, 3067507), (3067558, 3067559), (3216168, 3216171), (3216231, 3216241), (3216557, 3216558), (3216732, 3216733), (3216800, 3216801), (3216868, 3216869), (3216893, 3216895), (3216896, 3216897)]
kernel_rfl DEC_clearGrow.st1.fh94 : DEC_clearGrow.st1.s95.heap = setAll DEC_clearGrow.st1.s94.heap (rangesOf DEC_clearGrow.st1.s95.heap DEC_clearGrow.st1.fR94 ++ freshOf DEC_clearGrow.st1.s95.heap DEC_clearGrow.st1.s94.next DEC_clearGrow.st1.s95.next)
kernel_rfl DEC_clearGrow.st1.fb94 : footRB DEC_clearGrow.st1.s94 DEC_clearGrow.st1.s95 DEC_clearGrow.st1.fR94 = true
kernel_rfl DEC_clearGrow.st1.fc94 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s94.next && Nat.ble DEC_clearGrow.st1.s95.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR94 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa95 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s95 :=
  DEC_clearGrow.st1.fa94.step (stageFoot_ofRF DEC_clearGrow.st1.fh94 DEC_clearGrow.st1.fb94) (incl_of_footW DEC_clearGrow.st1.fb94 DEC_clearGrow.st1.fc94)

def DEC_clearGrow.st1.fR95 : List (Nat × Nat) := [(3123796, 3123797), (3216129, 3216130), (3216196, 3216197), (3217785, 3217786), (3217843, 3217844), (3217849, 3217850), (3217855, 3217856), (3217863, 3217864), (3217875, 3217878)]
kernel_rfl DEC_clearGrow.st1.fh95 : DEC_clearGrow.st1.s96.heap = setAll DEC_clearGrow.st1.s95.heap (rangesOf DEC_clearGrow.st1.s96.heap DEC_clearGrow.st1.fR95 ++ freshOf DEC_clearGrow.st1.s96.heap DEC_clearGrow.st1.s95.next DEC_clearGrow.st1.s96.next)
kernel_rfl DEC_clearGrow.st1.fb95 : footRB DEC_clearGrow.st1.s95 DEC_clearGrow.st1.s96 DEC_clearGrow.st1.fR95 = true
kernel_rfl DEC_clearGrow.st1.fc95 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s95.next && Nat.ble DEC_clearGrow.st1.s96.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR95 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa96 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s96 :=
  DEC_clearGrow.st1.fa95.step (stageFoot_ofRF DEC_clearGrow.st1.fh95 DEC_clearGrow.st1.fb95) (incl_of_footW DEC_clearGrow.st1.fb95 DEC_clearGrow.st1.fc95)

end Host.Load.Run.Tpl

import host.sim.template.a4dec_fill.st1.FootS1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_fill.st1.fR64 : List (Nat × Nat) := [(4841, 4842), (2672508, 2672509), (3039368, 3039369), (3039420, 3039421), (3186265, 3186268), (3186328, 3186329), (3186331, 3186338), (3186654, 3186655), (3186998, 3186999), (3187064, 3187065), (3187099, 3187100)]
kernel_rfl DEC_fill.st1.fh64 : DEC_fill.st1.s65.heap = setAll DEC_fill.st1.s64.heap (rangesOf DEC_fill.st1.s65.heap DEC_fill.st1.fR64 ++ freshOf DEC_fill.st1.s65.heap DEC_fill.st1.s64.next DEC_fill.st1.s65.next)
kernel_rfl DEC_fill.st1.fb64 : footRB DEC_fill.st1.s64 DEC_fill.st1.s65 DEC_fill.st1.fR64 = true
kernel_rfl DEC_fill.st1.fc64 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s64.next && Nat.ble DEC_fill.st1.s65.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR64 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa65 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s65 :=
  DEC_fill.st1.fa64.step (stageFoot_ofRF DEC_fill.st1.fh64 DEC_fill.st1.fb64) (incl_of_footW DEC_fill.st1.fb64 DEC_fill.st1.fc64)

def DEC_fill.st1.fR65 : List (Nat × Nat) := [(3123795, 3123796), (3186226, 3186227), (3186293, 3186294), (3187686, 3187687), (3187744, 3187745), (3187750, 3187751), (3187756, 3187757), (3188010, 3188011), (3188031, 3188032), (3188081, 3188082), (3188099, 3188101)]
kernel_rfl DEC_fill.st1.fh65 : DEC_fill.st1.s66.heap = setAll DEC_fill.st1.s65.heap (rangesOf DEC_fill.st1.s66.heap DEC_fill.st1.fR65 ++ freshOf DEC_fill.st1.s66.heap DEC_fill.st1.s65.next DEC_fill.st1.s66.next)
kernel_rfl DEC_fill.st1.fb65 : footRB DEC_fill.st1.s65 DEC_fill.st1.s66 DEC_fill.st1.fR65 = true
kernel_rfl DEC_fill.st1.fc65 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s65.next && Nat.ble DEC_fill.st1.s66.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR65 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa66 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s66 :=
  DEC_fill.st1.fa65.step (stageFoot_ofRF DEC_fill.st1.fh65 DEC_fill.st1.fb65) (incl_of_footW DEC_fill.st1.fb65 DEC_fill.st1.fc65)

def DEC_fill.st1.fR66 : List (Nat × Nat) := [(2672517, 2672518), (3041474, 3041475), (3041903, 3041904), (3188508, 3188514), (3188704, 3188705), (3188929, 3188930), (3189015, 3189016), (3189031, 3189032), (3189083, 3189085), (3189086, 3189087), (3189103, 3189104)]
kernel_rfl DEC_fill.st1.fh66 : DEC_fill.st1.s67.heap = setAll DEC_fill.st1.s66.heap (rangesOf DEC_fill.st1.s67.heap DEC_fill.st1.fR66 ++ freshOf DEC_fill.st1.s67.heap DEC_fill.st1.s66.next DEC_fill.st1.s67.next)
kernel_rfl DEC_fill.st1.fb66 : footRB DEC_fill.st1.s66 DEC_fill.st1.s67 DEC_fill.st1.fR66 = true
kernel_rfl DEC_fill.st1.fc66 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s66.next && Nat.ble DEC_fill.st1.s67.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR66 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa67 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s67 :=
  DEC_fill.st1.fa66.step (stageFoot_ofRF DEC_fill.st1.fh66 DEC_fill.st1.fb66) (incl_of_footW DEC_fill.st1.fb66 DEC_fill.st1.fc66)

def DEC_fill.st1.fR67 : List (Nat × Nat) := [(3123795, 3123796), (3188402, 3188403), (3188462, 3188465), (3188490, 3188491), (3188514, 3188515), (3189921, 3189922), (3189946, 3189947), (3190022, 3190027)]
kernel_rfl DEC_fill.st1.fh67 : DEC_fill.st1.s68.heap = setAll DEC_fill.st1.s67.heap (rangesOf DEC_fill.st1.s68.heap DEC_fill.st1.fR67 ++ freshOf DEC_fill.st1.s68.heap DEC_fill.st1.s67.next DEC_fill.st1.s68.next)
kernel_rfl DEC_fill.st1.fb67 : footRB DEC_fill.st1.s67 DEC_fill.st1.s68 DEC_fill.st1.fR67 = true
kernel_rfl DEC_fill.st1.fc67 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s67.next && Nat.ble DEC_fill.st1.s68.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR67 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa68 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s68 :=
  DEC_fill.st1.fa67.step (stageFoot_ofRF DEC_fill.st1.fh67 DEC_fill.st1.fb67) (incl_of_footW DEC_fill.st1.fb67 DEC_fill.st1.fc67)

def DEC_fill.st1.fR68 : List (Nat × Nat) := [(2672522, 2672523), (3043866, 3043867), (3190897, 3190902), (3190938, 3190939), (3191006, 3191007), (3191009, 3191019), (3191067, 3191068)]
kernel_rfl DEC_fill.st1.fh68 : DEC_fill.st1.s69.heap = setAll DEC_fill.st1.s68.heap (rangesOf DEC_fill.st1.s69.heap DEC_fill.st1.fR68 ++ freshOf DEC_fill.st1.s69.heap DEC_fill.st1.s68.next DEC_fill.st1.s69.next)
kernel_rfl DEC_fill.st1.fb68 : footRB DEC_fill.st1.s68 DEC_fill.st1.s69 DEC_fill.st1.fR68 = true
kernel_rfl DEC_fill.st1.fc68 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s68.next && Nat.ble DEC_fill.st1.s69.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR68 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa69 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s69 :=
  DEC_fill.st1.fa68.step (stageFoot_ofRF DEC_fill.st1.fh68 DEC_fill.st1.fb68) (incl_of_footW DEC_fill.st1.fb68 DEC_fill.st1.fc68)

def DEC_fill.st1.fR69 : List (Nat × Nat) := [(2672522, 2672523), (3044295, 3044296), (3190854, 3190857), (3190902, 3190907), (3191096, 3191097), (3191321, 3191322), (3191407, 3191408), (3191496, 3191497), (3191539, 3191541), (3191862, 3191863), (3191868, 3191869), (3191874, 3191875), (3191903, 3191905), (3191949, 3191950), (3191993, 3191994), (3192015, 3192017), (3192056, 3192057), (3192088, 3192089), (3192091, 3192101)]
kernel_rfl DEC_fill.st1.fh69 : DEC_fill.st1.s70.heap = setAll DEC_fill.st1.s69.heap (rangesOf DEC_fill.st1.s70.heap DEC_fill.st1.fR69 ++ freshOf DEC_fill.st1.s70.heap DEC_fill.st1.s69.next DEC_fill.st1.s70.next)
kernel_rfl DEC_fill.st1.fb69 : footRB DEC_fill.st1.s69 DEC_fill.st1.s70 DEC_fill.st1.fR69 = true
kernel_rfl DEC_fill.st1.fc69 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s69.next && Nat.ble DEC_fill.st1.s70.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR69 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa70 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s70 :=
  DEC_fill.st1.fa69.step (stageFoot_ofRF DEC_fill.st1.fh69 DEC_fill.st1.fb69) (incl_of_footW DEC_fill.st1.fb69 DEC_fill.st1.fc69)

def DEC_fill.st1.fR70 : List (Nat × Nat) := [(3123795, 3123796), (3190816, 3190817), (3190882, 3190883), (3192496, 3192497), (3192550, 3192551), (3192556, 3192557), (3192562, 3192563), (3192816, 3192817), (3192837, 3192838), (3192887, 3192888), (3192909, 3192911), (3192943, 3192944), (3192946, 3192956), (3193028, 3193029)]
kernel_rfl DEC_fill.st1.fh70 : DEC_fill.st1.s71.heap = setAll DEC_fill.st1.s70.heap (rangesOf DEC_fill.st1.s71.heap DEC_fill.st1.fR70 ++ freshOf DEC_fill.st1.s71.heap DEC_fill.st1.s70.next DEC_fill.st1.s71.next)
kernel_rfl DEC_fill.st1.fb70 : footRB DEC_fill.st1.s70 DEC_fill.st1.s71 DEC_fill.st1.fR70 = true
kernel_rfl DEC_fill.st1.fc70 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s70.next && Nat.ble DEC_fill.st1.s71.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR70 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa71 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s71 :=
  DEC_fill.st1.fa70.step (stageFoot_ofRF DEC_fill.st1.fh70 DEC_fill.st1.fb70) (incl_of_footW DEC_fill.st1.fb70 DEC_fill.st1.fc70)

def DEC_fill.st1.fR71 : List (Nat × Nat) := [(2672527, 2672528), (3046262, 3046263), (3046691, 3046692), (3193250, 3193253), (3193298, 3193303), (3193492, 3193493), (3193717, 3193718), (3193803, 3193804), (3193892, 3193893), (3193930, 3193937), (3193976, 3193978), (3194030, 3194031), (3194053, 3194056), (3194058, 3194060)]
kernel_rfl DEC_fill.st1.fh71 : DEC_fill.st1.s72.heap = setAll DEC_fill.st1.s71.heap (rangesOf DEC_fill.st1.s72.heap DEC_fill.st1.fR71 ++ freshOf DEC_fill.st1.s72.heap DEC_fill.st1.s71.next DEC_fill.st1.s72.next)
kernel_rfl DEC_fill.st1.fb71 : footRB DEC_fill.st1.s71 DEC_fill.st1.s72 DEC_fill.st1.fR71 = true
kernel_rfl DEC_fill.st1.fc71 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s71.next && Nat.ble DEC_fill.st1.s72.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR71 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa72 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s72 :=
  DEC_fill.st1.fa71.step (stageFoot_ofRF DEC_fill.st1.fh71 DEC_fill.st1.fb71) (incl_of_footW DEC_fill.st1.fb71 DEC_fill.st1.fc71)

def DEC_fill.st1.fR72 : List (Nat × Nat) := [(3123795, 3123796), (3193212, 3193213), (3193278, 3193279), (3194892, 3194893), (3194946, 3194947), (3194952, 3194953), (3194958, 3194959), (3194966, 3194967), (3194977, 3194981)]
kernel_rfl DEC_fill.st1.fh72 : DEC_fill.st1.s73.heap = setAll DEC_fill.st1.s72.heap (rangesOf DEC_fill.st1.s73.heap DEC_fill.st1.fR72 ++ freshOf DEC_fill.st1.s73.heap DEC_fill.st1.s72.next DEC_fill.st1.s73.next)
kernel_rfl DEC_fill.st1.fb72 : footRB DEC_fill.st1.s72 DEC_fill.st1.s73 DEC_fill.st1.fR72 = true
kernel_rfl DEC_fill.st1.fc72 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s72.next && Nat.ble DEC_fill.st1.s73.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR72 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa73 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s73 :=
  DEC_fill.st1.fa72.step (stageFoot_ofRF DEC_fill.st1.fh72 DEC_fill.st1.fb72) (incl_of_footW DEC_fill.st1.fb72 DEC_fill.st1.fc72)

def DEC_fill.st1.fR73 : List (Nat × Nat) := [(4841, 4842), (2672539, 2672540), (3048746, 3048747), (3048798, 3048799), (3195703, 3195715), (3195842, 3195843), (3195876, 3195877), (3195937, 3195938), (3195991, 3195995)]
kernel_rfl DEC_fill.st1.fh73 : DEC_fill.st1.s74.heap = setAll DEC_fill.st1.s73.heap (rangesOf DEC_fill.st1.s74.heap DEC_fill.st1.fR73 ++ freshOf DEC_fill.st1.s74.heap DEC_fill.st1.s73.next DEC_fill.st1.s74.next)
kernel_rfl DEC_fill.st1.fb73 : footRB DEC_fill.st1.s73 DEC_fill.st1.s74 DEC_fill.st1.fR73 = true
kernel_rfl DEC_fill.st1.fc73 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s73.next && Nat.ble DEC_fill.st1.s74.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR73 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa74 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s74 :=
  DEC_fill.st1.fa73.step (stageFoot_ofRF DEC_fill.st1.fh73 DEC_fill.st1.fb73) (incl_of_footW DEC_fill.st1.fb73 DEC_fill.st1.fc73)

def DEC_fill.st1.fR74 : List (Nat × Nat) := [(3123795, 3123796), (3195604, 3195605), (3195643, 3195646), (3195671, 3195672), (3195715, 3195716), (3196979, 3196980), (3196991, 3196992), (3197009, 3197010), (3197026, 3197027)]
kernel_rfl DEC_fill.st1.fh74 : DEC_fill.st1.s75.heap = setAll DEC_fill.st1.s74.heap (rangesOf DEC_fill.st1.s75.heap DEC_fill.st1.fR74 ++ freshOf DEC_fill.st1.s75.heap DEC_fill.st1.s74.next DEC_fill.st1.s75.next)
kernel_rfl DEC_fill.st1.fb74 : footRB DEC_fill.st1.s74 DEC_fill.st1.s75 DEC_fill.st1.fR74 = true
kernel_rfl DEC_fill.st1.fc74 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s74.next && Nat.ble DEC_fill.st1.s75.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR74 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa75 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s75 :=
  DEC_fill.st1.fa74.step (stageFoot_ofRF DEC_fill.st1.fh74 DEC_fill.st1.fb74) (incl_of_footW DEC_fill.st1.fb74 DEC_fill.st1.fc74)

def DEC_fill.st1.fR75 : List (Nat × Nat) := [(2672548, 2672549), (3050856, 3050857), (3197887, 3197892), (3197928, 3197929), (3197996, 3197997), (3197999, 3198009)]
kernel_rfl DEC_fill.st1.fh75 : DEC_fill.st1.s76.heap = setAll DEC_fill.st1.s75.heap (rangesOf DEC_fill.st1.s76.heap DEC_fill.st1.fR75 ++ freshOf DEC_fill.st1.s76.heap DEC_fill.st1.s75.next DEC_fill.st1.s76.next)
kernel_rfl DEC_fill.st1.fb75 : footRB DEC_fill.st1.s75 DEC_fill.st1.s76 DEC_fill.st1.fR75 = true
kernel_rfl DEC_fill.st1.fc75 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s75.next && Nat.ble DEC_fill.st1.s76.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR75 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa76 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s76 :=
  DEC_fill.st1.fa75.step (stageFoot_ofRF DEC_fill.st1.fh75 DEC_fill.st1.fb75) (incl_of_footW DEC_fill.st1.fb75 DEC_fill.st1.fc75)

def DEC_fill.st1.fR76 : List (Nat × Nat) := [(2672548, 2672549), (3051285, 3051286), (3197844, 3197847), (3197892, 3197897), (3198086, 3198087), (3198311, 3198312), (3198397, 3198398), (3198486, 3198487), (3198529, 3198531), (3198852, 3198853), (3198858, 3198859), (3198864, 3198865), (3198893, 3198895), (3198939, 3198940), (3198983, 3198984), (3199005, 3199007), (3199046, 3199047), (3199054, 3199056)]
kernel_rfl DEC_fill.st1.fh76 : DEC_fill.st1.s77.heap = setAll DEC_fill.st1.s76.heap (rangesOf DEC_fill.st1.s77.heap DEC_fill.st1.fR76 ++ freshOf DEC_fill.st1.s77.heap DEC_fill.st1.s76.next DEC_fill.st1.s77.next)
kernel_rfl DEC_fill.st1.fb76 : footRB DEC_fill.st1.s76 DEC_fill.st1.s77 DEC_fill.st1.fR76 = true
kernel_rfl DEC_fill.st1.fc76 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s76.next && Nat.ble DEC_fill.st1.s77.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR76 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa77 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s77 :=
  DEC_fill.st1.fa76.step (stageFoot_ofRF DEC_fill.st1.fh76 DEC_fill.st1.fb76) (incl_of_footW DEC_fill.st1.fb76 DEC_fill.st1.fc76)

def DEC_fill.st1.fR77 : List (Nat × Nat) := [(3123795, 3123796), (3197784, 3197785), (3197872, 3197873), (3199486, 3199487), (3199540, 3199541), (3199546, 3199547), (3199552, 3199553), (3199806, 3199807), (3199827, 3199828), (3199877, 3199878), (3199899, 3199901), (3199933, 3199934), (3199936, 3199946)]
kernel_rfl DEC_fill.st1.fh77 : DEC_fill.st1.s78.heap = setAll DEC_fill.st1.s77.heap (rangesOf DEC_fill.st1.s78.heap DEC_fill.st1.fR77 ++ freshOf DEC_fill.st1.s78.heap DEC_fill.st1.s77.next DEC_fill.st1.s78.next)
kernel_rfl DEC_fill.st1.fb77 : footRB DEC_fill.st1.s77 DEC_fill.st1.s78 DEC_fill.st1.fR77 = true
kernel_rfl DEC_fill.st1.fc77 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s77.next && Nat.ble DEC_fill.st1.s78.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR77 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa78 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s78 :=
  DEC_fill.st1.fa77.step (stageFoot_ofRF DEC_fill.st1.fh77 DEC_fill.st1.fb77) (incl_of_footW DEC_fill.st1.fb77 DEC_fill.st1.fc77)

def DEC_fill.st1.fR78 : List (Nat × Nat) := [(2672553, 2672554), (3053252, 3053253), (3053681, 3053682), (3200240, 3200241), (3200288, 3200293), (3200482, 3200483), (3200707, 3200708), (3200793, 3200794), (3200882, 3200883), (3200920, 3200927), (3200965, 3200968), (3200986, 3200988), (3200994, 3200995)]
kernel_rfl DEC_fill.st1.fh78 : DEC_fill.st1.s79.heap = setAll DEC_fill.st1.s78.heap (rangesOf DEC_fill.st1.s79.heap DEC_fill.st1.fR78 ++ freshOf DEC_fill.st1.s79.heap DEC_fill.st1.s78.next DEC_fill.st1.s79.next)
kernel_rfl DEC_fill.st1.fb78 : footRB DEC_fill.st1.s78 DEC_fill.st1.s79 DEC_fill.st1.fR78 = true
kernel_rfl DEC_fill.st1.fc78 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s78.next && Nat.ble DEC_fill.st1.s79.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR78 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa79 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s79 :=
  DEC_fill.st1.fa78.step (stageFoot_ofRF DEC_fill.st1.fh78 DEC_fill.st1.fb78) (incl_of_footW DEC_fill.st1.fb78 DEC_fill.st1.fc78)

def DEC_fill.st1.fR79 : List (Nat × Nat) := [(3123795, 3123796), (3200202, 3200203), (3200241, 3200243), (3200268, 3200269), (3201882, 3201883), (3201931, 3201933), (3201936, 3201937)]
kernel_rfl DEC_fill.st1.fh79 : DEC_fill.st1.s80.heap = setAll DEC_fill.st1.s79.heap (rangesOf DEC_fill.st1.s80.heap DEC_fill.st1.fR79 ++ freshOf DEC_fill.st1.s80.heap DEC_fill.st1.s79.next DEC_fill.st1.s80.next)
kernel_rfl DEC_fill.st1.fb79 : footRB DEC_fill.st1.s79 DEC_fill.st1.s80 DEC_fill.st1.fR79 = true
kernel_rfl DEC_fill.st1.fc79 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s79.next && Nat.ble DEC_fill.st1.s80.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR79 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa80 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s80 :=
  DEC_fill.st1.fa79.step (stageFoot_ofRF DEC_fill.st1.fh79 DEC_fill.st1.fb79) (incl_of_footW DEC_fill.st1.fb79 DEC_fill.st1.fc79)

def DEC_fill.st1.fR80 : List (Nat × Nat) := [(2672558, 2672559), (3055648, 3055649), (3202680, 3202684), (3202906, 3202910)]
kernel_rfl DEC_fill.st1.fh80 : DEC_fill.st1.s81.heap = setAll DEC_fill.st1.s80.heap (rangesOf DEC_fill.st1.s81.heap DEC_fill.st1.fR80 ++ freshOf DEC_fill.st1.s81.heap DEC_fill.st1.s80.next DEC_fill.st1.s81.next)
kernel_rfl DEC_fill.st1.fb80 : footRB DEC_fill.st1.s80 DEC_fill.st1.s81 DEC_fill.st1.fR80 = true
kernel_rfl DEC_fill.st1.fc80 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s80.next && Nat.ble DEC_fill.st1.s81.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR80 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa81 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s81 :=
  DEC_fill.st1.fa80.step (stageFoot_ofRF DEC_fill.st1.fh80 DEC_fill.st1.fb80) (incl_of_footW DEC_fill.st1.fb80 DEC_fill.st1.fc80)

def DEC_fill.st1.fR81 : List (Nat × Nat) := [(2672558, 2672559), (3056077, 3056078), (3202636, 3202639), (3202684, 3202689), (3202878, 3202879), (3203103, 3203104), (3203189, 3203190), (3203278, 3203279), (3203321, 3203323), (3203644, 3203645), (3203650, 3203651), (3203656, 3203657), (3203685, 3203687), (3203731, 3203732), (3203775, 3203776), (3203797, 3203799), (3203838, 3203839), (3203876, 3203883), (3203969, 3203970)]
kernel_rfl DEC_fill.st1.fh81 : DEC_fill.st1.s82.heap = setAll DEC_fill.st1.s81.heap (rangesOf DEC_fill.st1.s82.heap DEC_fill.st1.fR81 ++ freshOf DEC_fill.st1.s82.heap DEC_fill.st1.s81.next DEC_fill.st1.s82.next)
kernel_rfl DEC_fill.st1.fb81 : footRB DEC_fill.st1.s81 DEC_fill.st1.s82 DEC_fill.st1.fR81 = true
kernel_rfl DEC_fill.st1.fc81 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s81.next && Nat.ble DEC_fill.st1.s82.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR81 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa82 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s82 :=
  DEC_fill.st1.fa81.step (stageFoot_ofRF DEC_fill.st1.fh81 DEC_fill.st1.fb81) (incl_of_footW DEC_fill.st1.fb81 DEC_fill.st1.fc81)

def DEC_fill.st1.fR82 : List (Nat × Nat) := [(4841, 4842), (3123795, 3123796), (3202598, 3202599), (3202664, 3202665), (3204278, 3204279), (3204332, 3204333), (3204338, 3204339), (3204344, 3204345), (3204598, 3204599), (3204619, 3204620), (3204669, 3204670), (3204688, 3204689), (3204831, 3204832), (3204860, 3204861), (3204863, 3204873), (3204880, 3204881)]
kernel_rfl DEC_fill.st1.fh82 : DEC_fill.st1.s83.heap = setAll DEC_fill.st1.s82.heap (rangesOf DEC_fill.st1.s83.heap DEC_fill.st1.fR82 ++ freshOf DEC_fill.st1.s83.heap DEC_fill.st1.s82.next DEC_fill.st1.s83.next)
kernel_rfl DEC_fill.st1.fb82 : footRB DEC_fill.st1.s82 DEC_fill.st1.s83 DEC_fill.st1.fR82 = true
kernel_rfl DEC_fill.st1.fc82 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s82.next && Nat.ble DEC_fill.st1.s83.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR82 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa83 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s83 :=
  DEC_fill.st1.fa82.step (stageFoot_ofRF DEC_fill.st1.fh82 DEC_fill.st1.fb82) (incl_of_footW DEC_fill.st1.fb82 DEC_fill.st1.fc82)

def DEC_fill.st1.fR83 : List (Nat × Nat) := [(2672570, 2672571), (3058132, 3058133), (3058184, 3058185), (3205029, 3205032), (3205095, 3205102), (3205418, 3205419), (3205828, 3205829), (3205863, 3205864), (3205898, 3205899)]
kernel_rfl DEC_fill.st1.fh83 : DEC_fill.st1.s84.heap = setAll DEC_fill.st1.s83.heap (rangesOf DEC_fill.st1.s84.heap DEC_fill.st1.fR83 ++ freshOf DEC_fill.st1.s84.heap DEC_fill.st1.s83.next DEC_fill.st1.s84.next)
kernel_rfl DEC_fill.st1.fb83 : footRB DEC_fill.st1.s83 DEC_fill.st1.s84 DEC_fill.st1.fR83 = true
kernel_rfl DEC_fill.st1.fc83 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s83.next && Nat.ble DEC_fill.st1.s84.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR83 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa84 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s84 :=
  DEC_fill.st1.fa83.step (stageFoot_ofRF DEC_fill.st1.fh83 DEC_fill.st1.fb83) (incl_of_footW DEC_fill.st1.fb83 DEC_fill.st1.fc83)

def DEC_fill.st1.fR84 : List (Nat × Nat) := [(3123795, 3123796), (3204990, 3204991), (3205057, 3205058), (3206450, 3206451), (3206508, 3206509), (3206514, 3206515), (3206520, 3206521), (3206774, 3206775), (3206795, 3206796), (3206845, 3206846), (3206863, 3206865), (3206897, 3206898), (3206900, 3206910)]
kernel_rfl DEC_fill.st1.fh84 : DEC_fill.st1.s85.heap = setAll DEC_fill.st1.s84.heap (rangesOf DEC_fill.st1.s85.heap DEC_fill.st1.fR84 ++ freshOf DEC_fill.st1.s85.heap DEC_fill.st1.s84.next DEC_fill.st1.s85.next)
kernel_rfl DEC_fill.st1.fb84 : footRB DEC_fill.st1.s84 DEC_fill.st1.s85 DEC_fill.st1.fR84 = true
kernel_rfl DEC_fill.st1.fc84 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s84.next && Nat.ble DEC_fill.st1.s85.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR84 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa85 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s85 :=
  DEC_fill.st1.fa84.step (stageFoot_ofRF DEC_fill.st1.fh84 DEC_fill.st1.fb84) (incl_of_footW DEC_fill.st1.fb84 DEC_fill.st1.fc84)

def DEC_fill.st1.fR85 : List (Nat × Nat) := [(2672579, 2672580), (3060238, 3060239), (3060667, 3060668), (3207274, 3207279), (3207468, 3207469), (3207693, 3207694), (3207779, 3207780), (3207868, 3207869), (3207899, 3207913), (3207916, 3207917)]
kernel_rfl DEC_fill.st1.fh85 : DEC_fill.st1.s86.heap = setAll DEC_fill.st1.s85.heap (rangesOf DEC_fill.st1.s86.heap DEC_fill.st1.fR85 ++ freshOf DEC_fill.st1.s86.heap DEC_fill.st1.s85.next DEC_fill.st1.s86.next)
kernel_rfl DEC_fill.st1.fb85 : footRB DEC_fill.st1.s85 DEC_fill.st1.s86 DEC_fill.st1.fR85 = true
kernel_rfl DEC_fill.st1.fc85 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s85.next && Nat.ble DEC_fill.st1.s86.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR85 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa86 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s86 :=
  DEC_fill.st1.fa85.step (stageFoot_ofRF DEC_fill.st1.fh85 DEC_fill.st1.fb85) (incl_of_footW DEC_fill.st1.fb85 DEC_fill.st1.fc85)

def DEC_fill.st1.fR86 : List (Nat × Nat) := [(3123795, 3123796), (3207166, 3207167), (3207226, 3207229), (3207254, 3207255), (3208868, 3208869)]
kernel_rfl DEC_fill.st1.fh86 : DEC_fill.st1.s87.heap = setAll DEC_fill.st1.s86.heap (rangesOf DEC_fill.st1.s87.heap DEC_fill.st1.fR86 ++ freshOf DEC_fill.st1.s87.heap DEC_fill.st1.s86.next DEC_fill.st1.s87.next)
kernel_rfl DEC_fill.st1.fb86 : footRB DEC_fill.st1.s86 DEC_fill.st1.s87 DEC_fill.st1.fR86 = true
kernel_rfl DEC_fill.st1.fc86 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s86.next && Nat.ble DEC_fill.st1.s87.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR86 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa87 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s87 :=
  DEC_fill.st1.fa86.step (stageFoot_ofRF DEC_fill.st1.fh86 DEC_fill.st1.fb86) (incl_of_footW DEC_fill.st1.fb86 DEC_fill.st1.fc86)

def DEC_fill.st1.fR87 : List (Nat × Nat) := [(2672584, 2672585), (3062630, 3062631), (3209661, 3209666), (3209702, 3209703), (3209781, 3209783), (3209855, 3209856)]
kernel_rfl DEC_fill.st1.fh87 : DEC_fill.st1.s88.heap = setAll DEC_fill.st1.s87.heap (rangesOf DEC_fill.st1.s88.heap DEC_fill.st1.fR87 ++ freshOf DEC_fill.st1.s88.heap DEC_fill.st1.s87.next DEC_fill.st1.s88.next)
kernel_rfl DEC_fill.st1.fb87 : footRB DEC_fill.st1.s87 DEC_fill.st1.s88 DEC_fill.st1.fR87 = true
kernel_rfl DEC_fill.st1.fc87 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s87.next && Nat.ble DEC_fill.st1.s88.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR87 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa88 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s88 :=
  DEC_fill.st1.fa87.step (stageFoot_ofRF DEC_fill.st1.fh87 DEC_fill.st1.fb87) (incl_of_footW DEC_fill.st1.fb87 DEC_fill.st1.fc87)

def DEC_fill.st1.fR88 : List (Nat × Nat) := [(2672584, 2672585), (3063059, 3063060), (3209618, 3209621), (3209666, 3209671), (3209860, 3209861), (3210085, 3210086), (3210171, 3210172), (3210260, 3210261), (3210303, 3210305), (3210626, 3210627), (3210632, 3210633), (3210638, 3210639), (3210667, 3210669), (3210713, 3210714), (3210757, 3210758), (3210779, 3210781), (3210820, 3210821), (3210852, 3210853), (3210855, 3210865), (3210917, 3210918)]
kernel_rfl DEC_fill.st1.fh88 : DEC_fill.st1.s89.heap = setAll DEC_fill.st1.s88.heap (rangesOf DEC_fill.st1.s89.heap DEC_fill.st1.fR88 ++ freshOf DEC_fill.st1.s89.heap DEC_fill.st1.s88.next DEC_fill.st1.s89.next)
kernel_rfl DEC_fill.st1.fb88 : footRB DEC_fill.st1.s88 DEC_fill.st1.s89 DEC_fill.st1.fR88 = true
kernel_rfl DEC_fill.st1.fc88 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s88.next && Nat.ble DEC_fill.st1.s89.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR88 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa89 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s89 :=
  DEC_fill.st1.fa88.step (stageFoot_ofRF DEC_fill.st1.fh88 DEC_fill.st1.fb88) (incl_of_footW DEC_fill.st1.fb88 DEC_fill.st1.fc88)

def DEC_fill.st1.fR89 : List (Nat × Nat) := [(3123795, 3123796), (3209580, 3209581), (3209646, 3209647), (3211260, 3211261), (3211314, 3211315), (3211320, 3211321), (3211326, 3211327), (3211580, 3211581), (3211601, 3211602), (3211651, 3211652), (3211669, 3211671), (3211808, 3211809), (3211813, 3211814)]
kernel_rfl DEC_fill.st1.fh89 : DEC_fill.st1.s90.heap = setAll DEC_fill.st1.s89.heap (rangesOf DEC_fill.st1.s90.heap DEC_fill.st1.fR89 ++ freshOf DEC_fill.st1.s90.heap DEC_fill.st1.s89.next DEC_fill.st1.s90.next)
kernel_rfl DEC_fill.st1.fb89 : footRB DEC_fill.st1.s89 DEC_fill.st1.s90 DEC_fill.st1.fR89 = true
kernel_rfl DEC_fill.st1.fc89 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s89.next && Nat.ble DEC_fill.st1.s90.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR89 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa90 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s90 :=
  DEC_fill.st1.fa89.step (stageFoot_ofRF DEC_fill.st1.fh89 DEC_fill.st1.fb89) (incl_of_footW DEC_fill.st1.fb89 DEC_fill.st1.fc89)

def DEC_fill.st1.fR90 : List (Nat × Nat) := [(2672589, 2672590), (3065022, 3065023), (3065451, 3065452), (3212010, 3212013), (3212058, 3212063), (3212252, 3212253), (3212477, 3212478), (3212563, 3212564), (3212652, 3212653), (3212690, 3212697), (3212736, 3212738), (3212790, 3212791), (3212815, 3212816), (3212863, 3212866), (3212867, 3212868)]
kernel_rfl DEC_fill.st1.fh90 : DEC_fill.st1.s91.heap = setAll DEC_fill.st1.s90.heap (rangesOf DEC_fill.st1.s91.heap DEC_fill.st1.fR90 ++ freshOf DEC_fill.st1.s91.heap DEC_fill.st1.s90.next DEC_fill.st1.s91.next)
kernel_rfl DEC_fill.st1.fb90 : footRB DEC_fill.st1.s90 DEC_fill.st1.s91 DEC_fill.st1.fR90 = true
kernel_rfl DEC_fill.st1.fc90 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s90.next && Nat.ble DEC_fill.st1.s91.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR90 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa91 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s91 :=
  DEC_fill.st1.fa90.step (stageFoot_ofRF DEC_fill.st1.fh90 DEC_fill.st1.fb90) (incl_of_footW DEC_fill.st1.fb90 DEC_fill.st1.fc90)

def DEC_fill.st1.fR91 : List (Nat × Nat) := [(3123795, 3123796), (3211972, 3211973), (3212038, 3212039), (3213652, 3213653), (3213706, 3213707), (3213712, 3213713), (3213718, 3213719), (3213726, 3213727), (3213739, 3213741), (3213795, 3213796)]
kernel_rfl DEC_fill.st1.fh91 : DEC_fill.st1.s92.heap = setAll DEC_fill.st1.s91.heap (rangesOf DEC_fill.st1.s92.heap DEC_fill.st1.fR91 ++ freshOf DEC_fill.st1.s92.heap DEC_fill.st1.s91.next DEC_fill.st1.s92.next)
kernel_rfl DEC_fill.st1.fb91 : footRB DEC_fill.st1.s91 DEC_fill.st1.s92 DEC_fill.st1.fR91 = true
kernel_rfl DEC_fill.st1.fc91 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s91.next && Nat.ble DEC_fill.st1.s92.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR91 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa92 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s92 :=
  DEC_fill.st1.fa91.step (stageFoot_ofRF DEC_fill.st1.fh91 DEC_fill.st1.fb91) (incl_of_footW DEC_fill.st1.fb91 DEC_fill.st1.fc91)

def DEC_fill.st1.fR92 : List (Nat × Nat) := [(4841, 4842), (2672601, 2672602), (3067506, 3067507), (3067558, 3067559), (3214465, 3214475), (3214697, 3214698), (3214761, 3214762), (3214784, 3214786), (3214787, 3214788)]
kernel_rfl DEC_fill.st1.fh92 : DEC_fill.st1.s93.heap = setAll DEC_fill.st1.s92.heap (rangesOf DEC_fill.st1.s93.heap DEC_fill.st1.fR92 ++ freshOf DEC_fill.st1.s93.heap DEC_fill.st1.s92.next DEC_fill.st1.s93.next)
kernel_rfl DEC_fill.st1.fb92 : footRB DEC_fill.st1.s92 DEC_fill.st1.s93 DEC_fill.st1.fR92 = true
kernel_rfl DEC_fill.st1.fc92 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s92.next && Nat.ble DEC_fill.st1.s93.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR92 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa93 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s93 :=
  DEC_fill.st1.fa92.step (stageFoot_ofRF DEC_fill.st1.fh92 DEC_fill.st1.fb92) (incl_of_footW DEC_fill.st1.fb92 DEC_fill.st1.fc92)

def DEC_fill.st1.fR93 : List (Nat × Nat) := [(3123795, 3123796), (3214364, 3214365), (3214403, 3214406), (3214431, 3214432), (3214475, 3214476), (3215739, 3215740), (3215751, 3215752), (3215804, 3215805)]
kernel_rfl DEC_fill.st1.fh93 : DEC_fill.st1.s94.heap = setAll DEC_fill.st1.s93.heap (rangesOf DEC_fill.st1.s94.heap DEC_fill.st1.fR93 ++ freshOf DEC_fill.st1.s94.heap DEC_fill.st1.s93.next DEC_fill.st1.s94.next)
kernel_rfl DEC_fill.st1.fb93 : footRB DEC_fill.st1.s93 DEC_fill.st1.s94 DEC_fill.st1.fR93 = true
kernel_rfl DEC_fill.st1.fc93 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s93.next && Nat.ble DEC_fill.st1.s94.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR93 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa94 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s94 :=
  DEC_fill.st1.fa93.step (stageFoot_ofRF DEC_fill.st1.fh93 DEC_fill.st1.fb93) (incl_of_footW DEC_fill.st1.fb93 DEC_fill.st1.fc93)

def DEC_fill.st1.fR94 : List (Nat × Nat) := [(2672610, 2672611), (3069612, 3069613), (3216643, 3216648), (3216684, 3216685), (3216752, 3216753), (3216755, 3216765), (3216811, 3216813)]
kernel_rfl DEC_fill.st1.fh94 : DEC_fill.st1.s95.heap = setAll DEC_fill.st1.s94.heap (rangesOf DEC_fill.st1.s95.heap DEC_fill.st1.fR94 ++ freshOf DEC_fill.st1.s95.heap DEC_fill.st1.s94.next DEC_fill.st1.s95.next)
kernel_rfl DEC_fill.st1.fb94 : footRB DEC_fill.st1.s94 DEC_fill.st1.s95 DEC_fill.st1.fR94 = true
kernel_rfl DEC_fill.st1.fc94 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s94.next && Nat.ble DEC_fill.st1.s95.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR94 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa95 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s95 :=
  DEC_fill.st1.fa94.step (stageFoot_ofRF DEC_fill.st1.fh94 DEC_fill.st1.fb94) (incl_of_footW DEC_fill.st1.fb94 DEC_fill.st1.fc94)

def DEC_fill.st1.fR95 : List (Nat × Nat) := [(2672610, 2672611), (3070041, 3070042), (3216600, 3216603), (3216648, 3216653), (3216842, 3216843), (3217067, 3217068), (3217153, 3217154), (3217242, 3217243), (3217285, 3217287), (3217608, 3217609), (3217614, 3217615), (3217620, 3217621), (3217649, 3217651), (3217695, 3217696), (3217739, 3217740), (3217761, 3217763), (3217802, 3217803), (3217834, 3217835), (3217837, 3217847), (3217860, 3217861)]
kernel_rfl DEC_fill.st1.fh95 : DEC_fill.st1.s96.heap = setAll DEC_fill.st1.s95.heap (rangesOf DEC_fill.st1.s96.heap DEC_fill.st1.fR95 ++ freshOf DEC_fill.st1.s96.heap DEC_fill.st1.s95.next DEC_fill.st1.s96.next)
kernel_rfl DEC_fill.st1.fb95 : footRB DEC_fill.st1.s95 DEC_fill.st1.s96 DEC_fill.st1.fR95 = true
kernel_rfl DEC_fill.st1.fc95 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s95.next && Nat.ble DEC_fill.st1.s96.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR95 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa96 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s96 :=
  DEC_fill.st1.fa95.step (stageFoot_ofRF DEC_fill.st1.fh95 DEC_fill.st1.fb95) (incl_of_footW DEC_fill.st1.fb95 DEC_fill.st1.fc95)

end Host.Load.Run.Tpl

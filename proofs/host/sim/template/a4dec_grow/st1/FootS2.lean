import host.sim.template.a4dec_grow.st1.FootS1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_grow.st1.fR64 : List (Nat × Nat) := [(3123795, 3123796), (3185010, 3185011), (3185076, 3185077), (3186690, 3186691), (3186744, 3186745), (3186750, 3186751), (3186756, 3186757), (3187010, 3187011), (3187031, 3187032), (3187081, 3187082), (3187099, 3187101), (3187133, 3187134), (3187136, 3187146)]
kernel_rfl DEC_grow.st1.fh64 : DEC_grow.st1.s65.heap = setAll DEC_grow.st1.s64.heap (rangesOf DEC_grow.st1.s65.heap DEC_grow.st1.fR64 ++ freshOf DEC_grow.st1.s65.heap DEC_grow.st1.s64.next DEC_grow.st1.s65.next)
kernel_rfl DEC_grow.st1.fb64 : footRB DEC_grow.st1.s64 DEC_grow.st1.s65 DEC_grow.st1.fR64 = true
kernel_rfl DEC_grow.st1.fc64 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s64.next && Nat.ble DEC_grow.st1.s65.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR64 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa65 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s65 :=
  DEC_grow.st1.fa64.step (stageFoot_ofRF DEC_grow.st1.fh64 DEC_grow.st1.fb64) (incl_of_footW DEC_grow.st1.fb64 DEC_grow.st1.fc64)

def DEC_grow.st1.fR65 : List (Nat × Nat) := [(4841, 4842), (2672508, 2672509), (3039368, 3039369), (3039420, 3039421), (3187441, 3187444), (3187504, 3187514), (3187830, 3187831), (3188005, 3188006), (3188073, 3188074), (3188141, 3188142), (3188166, 3188168), (3188169, 3188170)]
kernel_rfl DEC_grow.st1.fh65 : DEC_grow.st1.s66.heap = setAll DEC_grow.st1.s65.heap (rangesOf DEC_grow.st1.s66.heap DEC_grow.st1.fR65 ++ freshOf DEC_grow.st1.s66.heap DEC_grow.st1.s65.next DEC_grow.st1.s66.next)
kernel_rfl DEC_grow.st1.fb65 : footRB DEC_grow.st1.s65 DEC_grow.st1.s66 DEC_grow.st1.fR65 = true
kernel_rfl DEC_grow.st1.fc65 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s65.next && Nat.ble DEC_grow.st1.s66.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR65 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa66 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s66 :=
  DEC_grow.st1.fa65.step (stageFoot_ofRF DEC_grow.st1.fh65 DEC_grow.st1.fb65) (incl_of_footW DEC_grow.st1.fb65 DEC_grow.st1.fc65)

def DEC_grow.st1.fR66 : List (Nat × Nat) := [(3123795, 3123796), (3187402, 3187403), (3187469, 3187470), (3189058, 3189059), (3189116, 3189117), (3189122, 3189123), (3189128, 3189129), (3189136, 3189137), (3189147, 3189151)]
kernel_rfl DEC_grow.st1.fh66 : DEC_grow.st1.s67.heap = setAll DEC_grow.st1.s66.heap (rangesOf DEC_grow.st1.s67.heap DEC_grow.st1.fR66 ++ freshOf DEC_grow.st1.s67.heap DEC_grow.st1.s66.next DEC_grow.st1.s67.next)
kernel_rfl DEC_grow.st1.fb66 : footRB DEC_grow.st1.s66 DEC_grow.st1.s67 DEC_grow.st1.fR66 = true
kernel_rfl DEC_grow.st1.fc66 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s66.next && Nat.ble DEC_grow.st1.s67.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR66 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa67 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s67 :=
  DEC_grow.st1.fa66.step (stageFoot_ofRF DEC_grow.st1.fh66 DEC_grow.st1.fb66) (incl_of_footW DEC_grow.st1.fb66 DEC_grow.st1.fc66)

def DEC_grow.st1.fR67 : List (Nat × Nat) := [(2672517, 2672518), (3041474, 3041475), (3189878, 3189882), (3190107, 3190108), (3190173, 3190175)]
kernel_rfl DEC_grow.st1.fh67 : DEC_grow.st1.s68.heap = setAll DEC_grow.st1.s67.heap (rangesOf DEC_grow.st1.s68.heap DEC_grow.st1.fR67 ++ freshOf DEC_grow.st1.s68.heap DEC_grow.st1.s67.next DEC_grow.st1.s68.next)
kernel_rfl DEC_grow.st1.fb67 : footRB DEC_grow.st1.s67 DEC_grow.st1.s68 DEC_grow.st1.fR67 = true
kernel_rfl DEC_grow.st1.fc67 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s67.next && Nat.ble DEC_grow.st1.s68.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR67 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa68 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s68 :=
  DEC_grow.st1.fa67.step (stageFoot_ofRF DEC_grow.st1.fh67 DEC_grow.st1.fb67) (incl_of_footW DEC_grow.st1.fb67 DEC_grow.st1.fc67)

def DEC_grow.st1.fR68 : List (Nat × Nat) := [(2672517, 2672518), (3041903, 3041904), (3189834, 3189837), (3189882, 3189887), (3190076, 3190077), (3190301, 3190302), (3190387, 3190388), (3190476, 3190477), (3190519, 3190521), (3190842, 3190843), (3190848, 3190849), (3190854, 3190855), (3190973, 3190974), (3191174, 3191175)]
kernel_rfl DEC_grow.st1.fh68 : DEC_grow.st1.s69.heap = setAll DEC_grow.st1.s68.heap (rangesOf DEC_grow.st1.s69.heap DEC_grow.st1.fR68 ++ freshOf DEC_grow.st1.s69.heap DEC_grow.st1.s68.next DEC_grow.st1.s69.next)
kernel_rfl DEC_grow.st1.fb68 : footRB DEC_grow.st1.s68 DEC_grow.st1.s69 DEC_grow.st1.fR68 = true
kernel_rfl DEC_grow.st1.fc68 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s68.next && Nat.ble DEC_grow.st1.s69.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR68 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa69 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s69 :=
  DEC_grow.st1.fa68.step (stageFoot_ofRF DEC_grow.st1.fh68 DEC_grow.st1.fb68) (incl_of_footW DEC_grow.st1.fb68 DEC_grow.st1.fc68)

def DEC_grow.st1.fR69 : List (Nat × Nat) := [(3123795, 3123796), (3189774, 3189775), (3189862, 3189863), (3191476, 3191477), (3191530, 3191531), (3191536, 3191537), (3191542, 3191543), (3191796, 3191797), (3191817, 3191818), (3191867, 3191868), (3191886, 3191887), (3192029, 3192030), (3192107, 3192108)]
kernel_rfl DEC_grow.st1.fh69 : DEC_grow.st1.s70.heap = setAll DEC_grow.st1.s69.heap (rangesOf DEC_grow.st1.s70.heap DEC_grow.st1.fR69 ++ freshOf DEC_grow.st1.s70.heap DEC_grow.st1.s69.next DEC_grow.st1.s70.next)
kernel_rfl DEC_grow.st1.fb69 : footRB DEC_grow.st1.s69 DEC_grow.st1.s70 DEC_grow.st1.fR69 = true
kernel_rfl DEC_grow.st1.fc69 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s69.next && Nat.ble DEC_grow.st1.s70.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR69 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa70 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s70 :=
  DEC_grow.st1.fa69.step (stageFoot_ofRF DEC_grow.st1.fh69 DEC_grow.st1.fb69) (incl_of_footW DEC_grow.st1.fb69 DEC_grow.st1.fc69)

def DEC_grow.st1.fR70 : List (Nat × Nat) := [(2672522, 2672523), (3043866, 3043867), (3044295, 3044296), (3192226, 3192229), (3192274, 3192279), (3192468, 3192469), (3192693, 3192694), (3192779, 3192780), (3192868, 3192869), (3192906, 3192913), (3192953, 3192954), (3193006, 3193007), (3193177, 3193178)]
kernel_rfl DEC_grow.st1.fh70 : DEC_grow.st1.s71.heap = setAll DEC_grow.st1.s70.heap (rangesOf DEC_grow.st1.s71.heap DEC_grow.st1.fR70 ++ freshOf DEC_grow.st1.s71.heap DEC_grow.st1.s70.next DEC_grow.st1.s71.next)
kernel_rfl DEC_grow.st1.fb70 : footRB DEC_grow.st1.s70 DEC_grow.st1.s71 DEC_grow.st1.fR70 = true
kernel_rfl DEC_grow.st1.fc70 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s70.next && Nat.ble DEC_grow.st1.s71.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR70 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa71 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s71 :=
  DEC_grow.st1.fa70.step (stageFoot_ofRF DEC_grow.st1.fh70 DEC_grow.st1.fb70) (incl_of_footW DEC_grow.st1.fb70 DEC_grow.st1.fc70)

def DEC_grow.st1.fR71 : List (Nat × Nat) := [(3123795, 3123796), (3192188, 3192189), (3192254, 3192255), (3193868, 3193869), (3193922, 3193923), (3193928, 3193929), (3193934, 3193935), (3193942, 3193943), (3193955, 3193957), (3194011, 3194012), (3194039, 3194040), (3194042, 3194052)]
kernel_rfl DEC_grow.st1.fh71 : DEC_grow.st1.s72.heap = setAll DEC_grow.st1.s71.heap (rangesOf DEC_grow.st1.s72.heap DEC_grow.st1.fR71 ++ freshOf DEC_grow.st1.s72.heap DEC_grow.st1.s71.next DEC_grow.st1.s72.next)
kernel_rfl DEC_grow.st1.fb71 : footRB DEC_grow.st1.s71 DEC_grow.st1.s72 DEC_grow.st1.fR71 = true
kernel_rfl DEC_grow.st1.fc71 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s71.next && Nat.ble DEC_grow.st1.s72.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR71 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa72 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s72 :=
  DEC_grow.st1.fa71.step (stageFoot_ofRF DEC_grow.st1.fh71 DEC_grow.st1.fb71) (incl_of_footW DEC_grow.st1.fb71 DEC_grow.st1.fc71)

def DEC_grow.st1.fR72 : List (Nat × Nat) := [(2672527, 2672528), (3046262, 3046263), (3046691, 3046692), (3194666, 3194673), (3194864, 3194865), (3195053, 3195054), (3195079, 3195083)]
kernel_rfl DEC_grow.st1.fh72 : DEC_grow.st1.s73.heap = setAll DEC_grow.st1.s72.heap (rangesOf DEC_grow.st1.s73.heap DEC_grow.st1.fR72 ++ freshOf DEC_grow.st1.s73.heap DEC_grow.st1.s72.next DEC_grow.st1.s73.next)
kernel_rfl DEC_grow.st1.fb72 : footRB DEC_grow.st1.s72 DEC_grow.st1.s73 DEC_grow.st1.fR72 = true
kernel_rfl DEC_grow.st1.fc72 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s72.next && Nat.ble DEC_grow.st1.s73.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR72 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa73 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s73 :=
  DEC_grow.st1.fa72.step (stageFoot_ofRF DEC_grow.st1.fh72 DEC_grow.st1.fb72) (incl_of_footW DEC_grow.st1.fb72 DEC_grow.st1.fc72)

def DEC_grow.st1.fR73 : List (Nat × Nat) := [(3123795, 3123796), (3194584, 3194585), (3194622, 3194625), (3194650, 3194651), (3194673, 3194675), (3196048, 3196049), (3196081, 3196082)]
kernel_rfl DEC_grow.st1.fh73 : DEC_grow.st1.s74.heap = setAll DEC_grow.st1.s73.heap (rangesOf DEC_grow.st1.s74.heap DEC_grow.st1.fR73 ++ freshOf DEC_grow.st1.s74.heap DEC_grow.st1.s73.next DEC_grow.st1.s74.next)
kernel_rfl DEC_grow.st1.fb73 : footRB DEC_grow.st1.s73 DEC_grow.st1.s74 DEC_grow.st1.fR73 = true
kernel_rfl DEC_grow.st1.fc73 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s73.next && Nat.ble DEC_grow.st1.s74.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR73 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa74 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s74 :=
  DEC_grow.st1.fa73.step (stageFoot_ofRF DEC_grow.st1.fh73 DEC_grow.st1.fb73) (incl_of_footW DEC_grow.st1.fb73 DEC_grow.st1.fc73)

def DEC_grow.st1.fR74 : List (Nat × Nat) := [(4841, 4842), (2672539, 2672540), (3197014, 3197015), (3197031, 3197035)]
kernel_rfl DEC_grow.st1.fh74 : DEC_grow.st1.s75.heap = setAll DEC_grow.st1.s74.heap (rangesOf DEC_grow.st1.s75.heap DEC_grow.st1.fR74 ++ freshOf DEC_grow.st1.s75.heap DEC_grow.st1.s74.next DEC_grow.st1.s75.next)
kernel_rfl DEC_grow.st1.fb74 : footRB DEC_grow.st1.s74 DEC_grow.st1.s75 DEC_grow.st1.fR74 = true
kernel_rfl DEC_grow.st1.fc74 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s74.next && Nat.ble DEC_grow.st1.s75.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR74 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa75 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s75 :=
  DEC_grow.st1.fa74.step (stageFoot_ofRF DEC_grow.st1.fh74 DEC_grow.st1.fb74) (incl_of_footW DEC_grow.st1.fb74 DEC_grow.st1.fc74)

def DEC_grow.st1.fR75 : List (Nat × Nat) := [(2672539, 2672540), (3048746, 3048747), (3048798, 3048799), (3197015, 3197018), (3197081, 3197088), (3197404, 3197405), (3197814, 3197815), (3197849, 3197850), (3197884, 3197885), (3197909, 3197911), (3197917, 3197924), (3198008, 3198009), (3198038, 3198039), (3198084, 3198085), (3198095, 3198096)]
kernel_rfl DEC_grow.st1.fh75 : DEC_grow.st1.s76.heap = setAll DEC_grow.st1.s75.heap (rangesOf DEC_grow.st1.s76.heap DEC_grow.st1.fR75 ++ freshOf DEC_grow.st1.s76.heap DEC_grow.st1.s75.next DEC_grow.st1.s76.next)
kernel_rfl DEC_grow.st1.fb75 : footRB DEC_grow.st1.s75 DEC_grow.st1.s76 DEC_grow.st1.fR75 = true
kernel_rfl DEC_grow.st1.fc75 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s75.next && Nat.ble DEC_grow.st1.s76.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR75 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa76 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s76 :=
  DEC_grow.st1.fa75.step (stageFoot_ofRF DEC_grow.st1.fh75 DEC_grow.st1.fb75) (incl_of_footW DEC_grow.st1.fb75 DEC_grow.st1.fc75)

def DEC_grow.st1.fR76 : List (Nat × Nat) := [(3123795, 3123796), (3196976, 3196977), (3197043, 3197044), (3198632, 3198633), (3198690, 3198691), (3198696, 3198697), (3198702, 3198703), (3198956, 3198957), (3198977, 3198978), (3199027, 3199028), (3199049, 3199051), (3199083, 3199084), (3199085, 3199096)]
kernel_rfl DEC_grow.st1.fh76 : DEC_grow.st1.s77.heap = setAll DEC_grow.st1.s76.heap (rangesOf DEC_grow.st1.s77.heap DEC_grow.st1.fR76 ++ freshOf DEC_grow.st1.s77.heap DEC_grow.st1.s76.next DEC_grow.st1.s77.next)
kernel_rfl DEC_grow.st1.fb76 : footRB DEC_grow.st1.s76 DEC_grow.st1.s77 DEC_grow.st1.fR76 = true
kernel_rfl DEC_grow.st1.fc76 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s76.next && Nat.ble DEC_grow.st1.s77.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR76 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa77 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s77 :=
  DEC_grow.st1.fa76.step (stageFoot_ofRF DEC_grow.st1.fh76 DEC_grow.st1.fb76) (incl_of_footW DEC_grow.st1.fb76 DEC_grow.st1.fc76)

def DEC_grow.st1.fR77 : List (Nat × Nat) := [(2672548, 2672549), (3050856, 3050857), (3051285, 3051286), (3199460, 3199464), (3199654, 3199655), (3199879, 3199880), (3199965, 3199966), (3200054, 3200055)]
kernel_rfl DEC_grow.st1.fh77 : DEC_grow.st1.s78.heap = setAll DEC_grow.st1.s77.heap (rangesOf DEC_grow.st1.s78.heap DEC_grow.st1.fR77 ++ freshOf DEC_grow.st1.s78.heap DEC_grow.st1.s77.next DEC_grow.st1.s78.next)
kernel_rfl DEC_grow.st1.fb77 : footRB DEC_grow.st1.s77 DEC_grow.st1.s78 DEC_grow.st1.fR77 = true
kernel_rfl DEC_grow.st1.fc77 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s77.next && Nat.ble DEC_grow.st1.s78.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR77 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa78 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s78 :=
  DEC_grow.st1.fa77.step (stageFoot_ofRF DEC_grow.st1.fh77 DEC_grow.st1.fb77) (incl_of_footW DEC_grow.st1.fb77 DEC_grow.st1.fc77)

def DEC_grow.st1.fR78 : List (Nat × Nat) := [(3123795, 3123796), (3199352, 3199353), (3199412, 3199415), (3199440, 3199441), (3199464, 3199465), (3200871, 3200872), (3201054, 3201055), (3201062, 3201064)]
kernel_rfl DEC_grow.st1.fh78 : DEC_grow.st1.s79.heap = setAll DEC_grow.st1.s78.heap (rangesOf DEC_grow.st1.s79.heap DEC_grow.st1.fR78 ++ freshOf DEC_grow.st1.s79.heap DEC_grow.st1.s78.next DEC_grow.st1.s79.next)
kernel_rfl DEC_grow.st1.fb78 : footRB DEC_grow.st1.s78 DEC_grow.st1.s79 DEC_grow.st1.fR78 = true
kernel_rfl DEC_grow.st1.fc78 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s78.next && Nat.ble DEC_grow.st1.s79.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR78 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa79 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s79 :=
  DEC_grow.st1.fa78.step (stageFoot_ofRF DEC_grow.st1.fh78 DEC_grow.st1.fb78) (incl_of_footW DEC_grow.st1.fb78 DEC_grow.st1.fc78)

def DEC_grow.st1.fR79 : List (Nat × Nat) := [(2672553, 2672554), (3053252, 3053253), (3201851, 3201856), (3201892, 3201893), (3201960, 3201961), (3201965, 3201973)]
kernel_rfl DEC_grow.st1.fh79 : DEC_grow.st1.s80.heap = setAll DEC_grow.st1.s79.heap (rangesOf DEC_grow.st1.s80.heap DEC_grow.st1.fR79 ++ freshOf DEC_grow.st1.s80.heap DEC_grow.st1.s79.next DEC_grow.st1.s80.next)
kernel_rfl DEC_grow.st1.fb79 : footRB DEC_grow.st1.s79 DEC_grow.st1.s80 DEC_grow.st1.fR79 = true
kernel_rfl DEC_grow.st1.fc79 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s79.next && Nat.ble DEC_grow.st1.s80.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR79 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa80 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s80 :=
  DEC_grow.st1.fa79.step (stageFoot_ofRF DEC_grow.st1.fh79 DEC_grow.st1.fb79) (incl_of_footW DEC_grow.st1.fb79 DEC_grow.st1.fc79)

def DEC_grow.st1.fR80 : List (Nat × Nat) := [(2672553, 2672554), (3053681, 3053682), (3201808, 3201811), (3201856, 3201861), (3202050, 3202051), (3202275, 3202276), (3202361, 3202362), (3202450, 3202451), (3202493, 3202495), (3202816, 3202817), (3202822, 3202823), (3202828, 3202829), (3202857, 3202859), (3202903, 3202904), (3202947, 3202948), (3202969, 3202971), (3203010, 3203011), (3203042, 3203043), (3203045, 3203055), (3203098, 3203099)]
kernel_rfl DEC_grow.st1.fh80 : DEC_grow.st1.s81.heap = setAll DEC_grow.st1.s80.heap (rangesOf DEC_grow.st1.s81.heap DEC_grow.st1.fR80 ++ freshOf DEC_grow.st1.s81.heap DEC_grow.st1.s80.next DEC_grow.st1.s81.next)
kernel_rfl DEC_grow.st1.fb80 : footRB DEC_grow.st1.s80 DEC_grow.st1.s81 DEC_grow.st1.fR80 = true
kernel_rfl DEC_grow.st1.fc80 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s80.next && Nat.ble DEC_grow.st1.s81.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR80 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa81 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s81 :=
  DEC_grow.st1.fa80.step (stageFoot_ofRF DEC_grow.st1.fh80 DEC_grow.st1.fb80) (incl_of_footW DEC_grow.st1.fb80 DEC_grow.st1.fc80)

def DEC_grow.st1.fR81 : List (Nat × Nat) := [(3123795, 3123796), (3201770, 3201771), (3201836, 3201837), (3203450, 3203451), (3203504, 3203505), (3203510, 3203511), (3203516, 3203517), (3203770, 3203771), (3203791, 3203792), (3203841, 3203842), (3203863, 3203865), (3203904, 3203910), (3204000, 3204001)]
kernel_rfl DEC_grow.st1.fh81 : DEC_grow.st1.s82.heap = setAll DEC_grow.st1.s81.heap (rangesOf DEC_grow.st1.s82.heap DEC_grow.st1.fR81 ++ freshOf DEC_grow.st1.s82.heap DEC_grow.st1.s81.next DEC_grow.st1.s82.next)
kernel_rfl DEC_grow.st1.fb81 : footRB DEC_grow.st1.s81 DEC_grow.st1.s82 DEC_grow.st1.fR81 = true
kernel_rfl DEC_grow.st1.fc81 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s81.next && Nat.ble DEC_grow.st1.s82.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR81 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa82 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s82 :=
  DEC_grow.st1.fa81.step (stageFoot_ofRF DEC_grow.st1.fh81 DEC_grow.st1.fb81) (incl_of_footW DEC_grow.st1.fb81 DEC_grow.st1.fc81)

def DEC_grow.st1.fR82 : List (Nat × Nat) := [(2672558, 2672559), (3055648, 3055649), (3056077, 3056078), (3204204, 3204207), (3204252, 3204257), (3204446, 3204447), (3204671, 3204672), (3204757, 3204758), (3204846, 3204847), (3204884, 3204891), (3204930, 3204932), (3204984, 3204985), (3205009, 3205010), (3205032, 3205033), (3205043, 3205044)]
kernel_rfl DEC_grow.st1.fh82 : DEC_grow.st1.s83.heap = setAll DEC_grow.st1.s82.heap (rangesOf DEC_grow.st1.s83.heap DEC_grow.st1.fR82 ++ freshOf DEC_grow.st1.s83.heap DEC_grow.st1.s82.next DEC_grow.st1.s83.next)
kernel_rfl DEC_grow.st1.fb82 : footRB DEC_grow.st1.s82 DEC_grow.st1.s83 DEC_grow.st1.fR82 = true
kernel_rfl DEC_grow.st1.fc82 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s82.next && Nat.ble DEC_grow.st1.s83.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR82 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa83 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s83 :=
  DEC_grow.st1.fa82.step (stageFoot_ofRF DEC_grow.st1.fh82 DEC_grow.st1.fb82) (incl_of_footW DEC_grow.st1.fb82 DEC_grow.st1.fc82)

def DEC_grow.st1.fR83 : List (Nat × Nat) := [(3123795, 3123796), (3204166, 3204167), (3204232, 3204233), (3205846, 3205847), (3205900, 3205901), (3205906, 3205907), (3205912, 3205913), (3205920, 3205921), (3205932, 3205935), (3205979, 3205983)]
kernel_rfl DEC_grow.st1.fh83 : DEC_grow.st1.s84.heap = setAll DEC_grow.st1.s83.heap (rangesOf DEC_grow.st1.s84.heap DEC_grow.st1.fR83 ++ freshOf DEC_grow.st1.s84.heap DEC_grow.st1.s83.next DEC_grow.st1.s84.next)
kernel_rfl DEC_grow.st1.fb83 : footRB DEC_grow.st1.s83 DEC_grow.st1.s84 DEC_grow.st1.fR83 = true
kernel_rfl DEC_grow.st1.fc83 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s83.next && Nat.ble DEC_grow.st1.s84.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR83 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa84 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s84 :=
  DEC_grow.st1.fa83.step (stageFoot_ofRF DEC_grow.st1.fh83 DEC_grow.st1.fb83) (incl_of_footW DEC_grow.st1.fb83 DEC_grow.st1.fc83)

def DEC_grow.st1.fR84 : List (Nat × Nat) := [(4841, 4842), (2672570, 2672571), (3058132, 3058133), (3058184, 3058185), (3206657, 3206665), (3206796, 3206797), (3206891, 3206892), (3206955, 3206956)]
kernel_rfl DEC_grow.st1.fh84 : DEC_grow.st1.s85.heap = setAll DEC_grow.st1.s84.heap (rangesOf DEC_grow.st1.s85.heap DEC_grow.st1.fR84 ++ freshOf DEC_grow.st1.s85.heap DEC_grow.st1.s84.next DEC_grow.st1.s85.next)
kernel_rfl DEC_grow.st1.fb84 : footRB DEC_grow.st1.s84 DEC_grow.st1.s85 DEC_grow.st1.fR84 = true
kernel_rfl DEC_grow.st1.fc84 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s84.next && Nat.ble DEC_grow.st1.s85.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR84 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa85 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s85 :=
  DEC_grow.st1.fa84.step (stageFoot_ofRF DEC_grow.st1.fh84 DEC_grow.st1.fb84) (incl_of_footW DEC_grow.st1.fb84 DEC_grow.st1.fc84)

def DEC_grow.st1.fR85 : List (Nat × Nat) := [(3206597, 3206600), (3206625, 3206626), (3206664, 3206670), (3206986, 3206987), (3207431, 3207432), (3207906, 3207907), (3207955, 3207956), (3208004, 3208005)]
kernel_rfl DEC_grow.st1.fh85 : DEC_grow.st1.s86.heap = setAll DEC_grow.st1.s85.heap (rangesOf DEC_grow.st1.s86.heap DEC_grow.st1.fR85 ++ freshOf DEC_grow.st1.s86.heap DEC_grow.st1.s85.next DEC_grow.st1.s86.next)
kernel_rfl DEC_grow.st1.fb85 : footRB DEC_grow.st1.s85 DEC_grow.st1.s86 DEC_grow.st1.fR85 = true
kernel_rfl DEC_grow.st1.fc85 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s85.next && Nat.ble DEC_grow.st1.s86.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR85 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa86 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s86 :=
  DEC_grow.st1.fa85.step (stageFoot_ofRF DEC_grow.st1.fh85 DEC_grow.st1.fb85) (incl_of_footW DEC_grow.st1.fb85 DEC_grow.st1.fc85)

def DEC_grow.st1.fR86 : List (Nat × Nat) := [(2672579, 2672580), (3060238, 3060239), (3123795, 3123796), (3206558, 3206559)]
kernel_rfl DEC_grow.st1.fh86 : DEC_grow.st1.s87.heap = setAll DEC_grow.st1.s86.heap (rangesOf DEC_grow.st1.s87.heap DEC_grow.st1.fR86 ++ freshOf DEC_grow.st1.s87.heap DEC_grow.st1.s86.next DEC_grow.st1.s87.next)
kernel_rfl DEC_grow.st1.fb86 : footRB DEC_grow.st1.s86 DEC_grow.st1.s87 DEC_grow.st1.fR86 = true
kernel_rfl DEC_grow.st1.fc86 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s86.next && Nat.ble DEC_grow.st1.s87.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR86 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa87 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s87 :=
  DEC_grow.st1.fa86.step (stageFoot_ofRF DEC_grow.st1.fh86 DEC_grow.st1.fb86) (incl_of_footW DEC_grow.st1.fb86 DEC_grow.st1.fc86)

def DEC_grow.st1.fR87 : List (Nat × Nat) := [(2672579, 2672580), (3060667, 3060668), (3208990, 3208993), (3209038, 3209043), (3209232, 3209233), (3209457, 3209458), (3209543, 3209544), (3209632, 3209633), (3209672, 3209677), (3209941, 3209942), (3209956, 3209958), (3209998, 3209999), (3210004, 3210005), (3210010, 3210011)]
kernel_rfl DEC_grow.st1.fh87 : DEC_grow.st1.s88.heap = setAll DEC_grow.st1.s87.heap (rangesOf DEC_grow.st1.s88.heap DEC_grow.st1.fR87 ++ freshOf DEC_grow.st1.s88.heap DEC_grow.st1.s87.next DEC_grow.st1.s88.next)
kernel_rfl DEC_grow.st1.fb87 : footRB DEC_grow.st1.s87 DEC_grow.st1.s88 DEC_grow.st1.fR87 = true
kernel_rfl DEC_grow.st1.fc87 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s87.next && Nat.ble DEC_grow.st1.s88.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR87 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa88 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s88 :=
  DEC_grow.st1.fa87.step (stageFoot_ofRF DEC_grow.st1.fh87 DEC_grow.st1.fb87) (incl_of_footW DEC_grow.st1.fb87 DEC_grow.st1.fc87)

def DEC_grow.st1.fR88 : List (Nat × Nat) := [(3123795, 3123796), (3208930, 3208931), (3209018, 3209019), (3210632, 3210633), (3210686, 3210687), (3210692, 3210693), (3210698, 3210699), (3210706, 3210707), (3210720, 3210721), (3210921, 3210922), (3210944, 3210946), (3210947, 3210948)]
kernel_rfl DEC_grow.st1.fh88 : DEC_grow.st1.s89.heap = setAll DEC_grow.st1.s88.heap (rangesOf DEC_grow.st1.s89.heap DEC_grow.st1.fR88 ++ freshOf DEC_grow.st1.s89.heap DEC_grow.st1.s88.next DEC_grow.st1.s89.next)
kernel_rfl DEC_grow.st1.fb88 : footRB DEC_grow.st1.s88 DEC_grow.st1.s89 DEC_grow.st1.fR88 = true
kernel_rfl DEC_grow.st1.fc88 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s88.next && Nat.ble DEC_grow.st1.s89.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR88 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa89 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s89 :=
  DEC_grow.st1.fa88.step (stageFoot_ofRF DEC_grow.st1.fh88 DEC_grow.st1.fb88) (incl_of_footW DEC_grow.st1.fb88 DEC_grow.st1.fc88)

def DEC_grow.st1.fR89 : List (Nat × Nat) := [(2672584, 2672585), (3062630, 3062631), (3063059, 3063060), (3211427, 3211434), (3211624, 3211625), (3211849, 3211850), (3211862, 3211863), (3211935, 3211936)]
kernel_rfl DEC_grow.st1.fh89 : DEC_grow.st1.s90.heap = setAll DEC_grow.st1.s89.heap (rangesOf DEC_grow.st1.s90.heap DEC_grow.st1.fR89 ++ freshOf DEC_grow.st1.s90.heap DEC_grow.st1.s89.next DEC_grow.st1.s90.next)
kernel_rfl DEC_grow.st1.fb89 : footRB DEC_grow.st1.s89 DEC_grow.st1.s90 DEC_grow.st1.fR89 = true
kernel_rfl DEC_grow.st1.fc89 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s89.next && Nat.ble DEC_grow.st1.s90.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR89 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa90 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s90 :=
  DEC_grow.st1.fa89.step (stageFoot_ofRF DEC_grow.st1.fh89 DEC_grow.st1.fb89) (incl_of_footW DEC_grow.st1.fb89 DEC_grow.st1.fc89)

def DEC_grow.st1.fR90 : List (Nat × Nat) := [(3123795, 3123796), (3211344, 3211345), (3211382, 3211385), (3211410, 3211411), (3211434, 3211435), (3212841, 3212842), (3212866, 3212867), (3212934, 3212935), (3212937, 3212947)]
kernel_rfl DEC_grow.st1.fh90 : DEC_grow.st1.s91.heap = setAll DEC_grow.st1.s90.heap (rangesOf DEC_grow.st1.s91.heap DEC_grow.st1.fR90 ++ freshOf DEC_grow.st1.s91.heap DEC_grow.st1.s90.next DEC_grow.st1.s91.next)
kernel_rfl DEC_grow.st1.fb90 : footRB DEC_grow.st1.s90 DEC_grow.st1.s91 DEC_grow.st1.fR90 = true
kernel_rfl DEC_grow.st1.fc90 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s90.next && Nat.ble DEC_grow.st1.s91.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR90 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa91 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s91 :=
  DEC_grow.st1.fa90.step (stageFoot_ofRF DEC_grow.st1.fh90 DEC_grow.st1.fb90) (incl_of_footW DEC_grow.st1.fb90 DEC_grow.st1.fc90)

def DEC_grow.st1.fR91 : List (Nat × Nat) := [(2672589, 2672590), (3065022, 3065023), (3213817, 3213822), (3213858, 3213859), (3213890, 3213891)]
kernel_rfl DEC_grow.st1.fh91 : DEC_grow.st1.s92.heap = setAll DEC_grow.st1.s91.heap (rangesOf DEC_grow.st1.s92.heap DEC_grow.st1.fR91 ++ freshOf DEC_grow.st1.s92.heap DEC_grow.st1.s91.next DEC_grow.st1.s92.next)
kernel_rfl DEC_grow.st1.fb91 : footRB DEC_grow.st1.s91 DEC_grow.st1.s92 DEC_grow.st1.fR91 = true
kernel_rfl DEC_grow.st1.fc91 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s91.next && Nat.ble DEC_grow.st1.s92.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR91 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa92 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s92 :=
  DEC_grow.st1.fa91.step (stageFoot_ofRF DEC_grow.st1.fh91 DEC_grow.st1.fb91) (incl_of_footW DEC_grow.st1.fb91 DEC_grow.st1.fc91)

def DEC_grow.st1.fR92 : List (Nat × Nat) := [(2672589, 2672590), (3065451, 3065452), (3213774, 3213777), (3213822, 3213827), (3214016, 3214017), (3214241, 3214242), (3214327, 3214328), (3214416, 3214417), (3214459, 3214461), (3214782, 3214783), (3214788, 3214789), (3214794, 3214795), (3214823, 3214825), (3214869, 3214870), (3214913, 3214914), (3214931, 3214937)]
kernel_rfl DEC_grow.st1.fh92 : DEC_grow.st1.s93.heap = setAll DEC_grow.st1.s92.heap (rangesOf DEC_grow.st1.s93.heap DEC_grow.st1.fR92 ++ freshOf DEC_grow.st1.s93.heap DEC_grow.st1.s92.next DEC_grow.st1.s93.next)
kernel_rfl DEC_grow.st1.fb92 : footRB DEC_grow.st1.s92 DEC_grow.st1.s93 DEC_grow.st1.fR92 = true
kernel_rfl DEC_grow.st1.fc92 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s92.next && Nat.ble DEC_grow.st1.s93.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR92 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa93 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s93 :=
  DEC_grow.st1.fa92.step (stageFoot_ofRF DEC_grow.st1.fh92 DEC_grow.st1.fb92) (incl_of_footW DEC_grow.st1.fb92 DEC_grow.st1.fc92)

def DEC_grow.st1.fR93 : List (Nat × Nat) := [(3123795, 3123796), (3213736, 3213737), (3213802, 3213803), (3215416, 3215417), (3215470, 3215471), (3215476, 3215477), (3215482, 3215483), (3215736, 3215737), (3215757, 3215758), (3215807, 3215808), (3215825, 3215827), (3215859, 3215860), (3215862, 3215872)]
kernel_rfl DEC_grow.st1.fh93 : DEC_grow.st1.s94.heap = setAll DEC_grow.st1.s93.heap (rangesOf DEC_grow.st1.s94.heap DEC_grow.st1.fR93 ++ freshOf DEC_grow.st1.s94.heap DEC_grow.st1.s93.next DEC_grow.st1.s94.next)
kernel_rfl DEC_grow.st1.fb93 : footRB DEC_grow.st1.s93 DEC_grow.st1.s94 DEC_grow.st1.fR93 = true
kernel_rfl DEC_grow.st1.fc93 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s93.next && Nat.ble DEC_grow.st1.s94.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR93 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa94 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s94 :=
  DEC_grow.st1.fa93.step (stageFoot_ofRF DEC_grow.st1.fh93 DEC_grow.st1.fb93) (incl_of_footW DEC_grow.st1.fb93 DEC_grow.st1.fc93)

def DEC_grow.st1.fR94 : List (Nat × Nat) := [(4841, 4842), (2672601, 2672602), (3067506, 3067507), (3067558, 3067559), (3216167, 3216170), (3216230, 3216240), (3216556, 3216557), (3216731, 3216732), (3216799, 3216800), (3216867, 3216868), (3216892, 3216894), (3216895, 3216896)]
kernel_rfl DEC_grow.st1.fh94 : DEC_grow.st1.s95.heap = setAll DEC_grow.st1.s94.heap (rangesOf DEC_grow.st1.s95.heap DEC_grow.st1.fR94 ++ freshOf DEC_grow.st1.s95.heap DEC_grow.st1.s94.next DEC_grow.st1.s95.next)
kernel_rfl DEC_grow.st1.fb94 : footRB DEC_grow.st1.s94 DEC_grow.st1.s95 DEC_grow.st1.fR94 = true
kernel_rfl DEC_grow.st1.fc94 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s94.next && Nat.ble DEC_grow.st1.s95.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR94 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa95 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s95 :=
  DEC_grow.st1.fa94.step (stageFoot_ofRF DEC_grow.st1.fh94 DEC_grow.st1.fb94) (incl_of_footW DEC_grow.st1.fb94 DEC_grow.st1.fc94)

def DEC_grow.st1.fR95 : List (Nat × Nat) := [(3123795, 3123796), (3216128, 3216129), (3216195, 3216196), (3217784, 3217785), (3217842, 3217843), (3217848, 3217849), (3217854, 3217855), (3217862, 3217863), (3217874, 3217877)]
kernel_rfl DEC_grow.st1.fh95 : DEC_grow.st1.s96.heap = setAll DEC_grow.st1.s95.heap (rangesOf DEC_grow.st1.s96.heap DEC_grow.st1.fR95 ++ freshOf DEC_grow.st1.s96.heap DEC_grow.st1.s95.next DEC_grow.st1.s96.next)
kernel_rfl DEC_grow.st1.fb95 : footRB DEC_grow.st1.s95 DEC_grow.st1.s96 DEC_grow.st1.fR95 = true
kernel_rfl DEC_grow.st1.fc95 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s95.next && Nat.ble DEC_grow.st1.s96.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR95 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa96 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s96 :=
  DEC_grow.st1.fa95.step (stageFoot_ofRF DEC_grow.st1.fh95 DEC_grow.st1.fb95) (incl_of_footW DEC_grow.st1.fb95 DEC_grow.st1.fc95)

end Host.Load.Run.Tpl

import host.sim.template.a4dec_grow.st1.FootS3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_grow.st1.fR128 : List (Nat × Nat) := [(2672708, 2672709), (3100475, 3100476), (3249682, 3249685), (3249730, 3249735), (3249924, 3249925), (3250049, 3250050), (3250135, 3250136), (3250224, 3250225), (3250267, 3250269), (3250590, 3250591), (3250596, 3250597), (3250602, 3250603), (3250622, 3250633), (3250635, 3250637)]
kernel_rfl DEC_grow.st1.fh128 : DEC_grow.st1.s129.heap = setAll DEC_grow.st1.s128.heap (rangesOf DEC_grow.st1.s129.heap DEC_grow.st1.fR128 ++ freshOf DEC_grow.st1.s129.heap DEC_grow.st1.s128.next DEC_grow.st1.s129.next)
kernel_rfl DEC_grow.st1.fb128 : footRB DEC_grow.st1.s128 DEC_grow.st1.s129 DEC_grow.st1.fR128 = true
kernel_rfl DEC_grow.st1.fc128 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s128.next && Nat.ble DEC_grow.st1.s129.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR128 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa129 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s129 :=
  DEC_grow.st1.fa128.step (stageFoot_ofRF DEC_grow.st1.fh128 DEC_grow.st1.fb128) (incl_of_footW DEC_grow.st1.fb128 DEC_grow.st1.fc128)

def DEC_grow.st1.fR129 : List (Nat × Nat) := [(3123795, 3123796), (3249644, 3249645), (3249710, 3249711), (3251224, 3251225), (3251278, 3251279), (3251284, 3251285), (3251290, 3251291), (3251298, 3251299), (3251544, 3251545)]
kernel_rfl DEC_grow.st1.fh129 : DEC_grow.st1.s130.heap = setAll DEC_grow.st1.s129.heap (rangesOf DEC_grow.st1.s130.heap DEC_grow.st1.fR129 ++ freshOf DEC_grow.st1.s130.heap DEC_grow.st1.s129.next DEC_grow.st1.s130.next)
kernel_rfl DEC_grow.st1.fb129 : footRB DEC_grow.st1.s129 DEC_grow.st1.s130 DEC_grow.st1.fR129 = true
kernel_rfl DEC_grow.st1.fc129 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s129.next && Nat.ble DEC_grow.st1.s130.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR129 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa130 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s130 :=
  DEC_grow.st1.fa129.step (stageFoot_ofRF DEC_grow.st1.fh129 DEC_grow.st1.fb129) (incl_of_footW DEC_grow.st1.fb129 DEC_grow.st1.fc129)

def DEC_grow.st1.fR130 : List (Nat × Nat) := [(2672713, 2672714), (3102238, 3102239), (3102667, 3102668), (3251974, 3251977), (3252022, 3252027), (3252116, 3252117), (3252241, 3252242), (3252327, 3252328), (3252416, 3252417), (3252454, 3252461), (3252500, 3252502), (3252554, 3252555), (3252579, 3252580), (3252602, 3252603), (3252613, 3252614)]
kernel_rfl DEC_grow.st1.fh130 : DEC_grow.st1.s131.heap = setAll DEC_grow.st1.s130.heap (rangesOf DEC_grow.st1.s131.heap DEC_grow.st1.fR130 ++ freshOf DEC_grow.st1.s131.heap DEC_grow.st1.s130.next DEC_grow.st1.s131.next)
kernel_rfl DEC_grow.st1.fb130 : footRB DEC_grow.st1.s130 DEC_grow.st1.s131 DEC_grow.st1.fR130 = true
kernel_rfl DEC_grow.st1.fc130 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s130.next && Nat.ble DEC_grow.st1.s131.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR130 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa131 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s131 :=
  DEC_grow.st1.fa130.step (stageFoot_ofRF DEC_grow.st1.fh130 DEC_grow.st1.fb130) (incl_of_footW DEC_grow.st1.fb130 DEC_grow.st1.fc130)

def DEC_grow.st1.fR131 : List (Nat × Nat) := [(3123795, 3123796), (3251936, 3251937), (3252002, 3252003), (3253316, 3253317), (3253370, 3253371), (3253376, 3253377), (3253382, 3253383), (3253390, 3253391), (3253403, 3253405), (3253459, 3253460), (3253487, 3253488), (3253490, 3253500)]
kernel_rfl DEC_grow.st1.fh131 : DEC_grow.st1.s132.heap = setAll DEC_grow.st1.s131.heap (rangesOf DEC_grow.st1.s132.heap DEC_grow.st1.fR131 ++ freshOf DEC_grow.st1.s132.heap DEC_grow.st1.s131.next DEC_grow.st1.s132.next)
kernel_rfl DEC_grow.st1.fb131 : footRB DEC_grow.st1.s131 DEC_grow.st1.s132 DEC_grow.st1.fR131 = true
kernel_rfl DEC_grow.st1.fc131 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s131.next && Nat.ble DEC_grow.st1.s132.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR131 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa132 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s132 :=
  DEC_grow.st1.fa131.step (stageFoot_ofRF DEC_grow.st1.fh131 DEC_grow.st1.fb131) (incl_of_footW DEC_grow.st1.fb131 DEC_grow.st1.fc131)

def DEC_grow.st1.fR132 : List (Nat × Nat) := [(4841, 4842), (2672725, 2672726), (3104626, 3104627), (3104678, 3104679), (3254134, 3254142), (3254365, 3254366), (3254460, 3254461), (3254473, 3254474), (3254546, 3254547)]
kernel_rfl DEC_grow.st1.fh132 : DEC_grow.st1.s133.heap = setAll DEC_grow.st1.s132.heap (rangesOf DEC_grow.st1.s133.heap DEC_grow.st1.fR132 ++ freshOf DEC_grow.st1.s133.heap DEC_grow.st1.s132.next DEC_grow.st1.s133.next)
kernel_rfl DEC_grow.st1.fb132 : footRB DEC_grow.st1.s132 DEC_grow.st1.s133 DEC_grow.st1.fR132 = true
kernel_rfl DEC_grow.st1.fc132 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s132.next && Nat.ble DEC_grow.st1.s133.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR132 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa133 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s133 :=
  DEC_grow.st1.fa132.step (stageFoot_ofRF DEC_grow.st1.fh132 DEC_grow.st1.fb132) (incl_of_footW DEC_grow.st1.fb132 DEC_grow.st1.fc132)

def DEC_grow.st1.fR133 : List (Nat × Nat) := [(3123795, 3123796), (3254032, 3254033), (3254071, 3254074), (3254099, 3254100), (3254142, 3254144), (3255550, 3255551), (3255575, 3255576), (3255591, 3255595)]
kernel_rfl DEC_grow.st1.fh133 : DEC_grow.st1.s134.heap = setAll DEC_grow.st1.s133.heap (rangesOf DEC_grow.st1.s134.heap DEC_grow.st1.fR133 ++ freshOf DEC_grow.st1.s134.heap DEC_grow.st1.s133.next DEC_grow.st1.s134.next)
kernel_rfl DEC_grow.st1.fb133 : footRB DEC_grow.st1.s133 DEC_grow.st1.s134 DEC_grow.st1.fR133 = true
kernel_rfl DEC_grow.st1.fc133 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s133.next && Nat.ble DEC_grow.st1.s134.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR133 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa134 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s134 :=
  DEC_grow.st1.fa133.step (stageFoot_ofRF DEC_grow.st1.fh133 DEC_grow.st1.fb133) (incl_of_footW DEC_grow.st1.fb133 DEC_grow.st1.fc133)

def DEC_grow.st1.fR134 : List (Nat × Nat) := [(2672734, 2672735), (3106536, 3106537), (3256511, 3256516), (3256537, 3256538), (3256555, 3256556), (3256571, 3256573)]
kernel_rfl DEC_grow.st1.fh134 : DEC_grow.st1.s135.heap = setAll DEC_grow.st1.s134.heap (rangesOf DEC_grow.st1.s135.heap DEC_grow.st1.fR134 ++ freshOf DEC_grow.st1.s135.heap DEC_grow.st1.s134.next DEC_grow.st1.s135.next)
kernel_rfl DEC_grow.st1.fb134 : footRB DEC_grow.st1.s134 DEC_grow.st1.s135 DEC_grow.st1.fR134 = true
kernel_rfl DEC_grow.st1.fc134 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s134.next && Nat.ble DEC_grow.st1.s135.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR134 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa135 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s135 :=
  DEC_grow.st1.fa134.step (stageFoot_ofRF DEC_grow.st1.fh134 DEC_grow.st1.fb134) (incl_of_footW DEC_grow.st1.fb134 DEC_grow.st1.fc134)

def DEC_grow.st1.fR135 : List (Nat × Nat) := [(2672734, 2672735), (3106965, 3106966), (3256468, 3256471), (3256516, 3256521), (3256610, 3256611), (3256735, 3256736), (3256821, 3256822), (3256910, 3256911), (3256953, 3256955), (3257276, 3257277), (3257282, 3257283), (3257288, 3257289), (3257317, 3257319), (3257363, 3257364), (3257407, 3257408), (3257429, 3257431), (3257470, 3257471), (3257608, 3257609)]
kernel_rfl DEC_grow.st1.fh135 : DEC_grow.st1.s136.heap = setAll DEC_grow.st1.s135.heap (rangesOf DEC_grow.st1.s136.heap DEC_grow.st1.fR135 ++ freshOf DEC_grow.st1.s136.heap DEC_grow.st1.s135.next DEC_grow.st1.s136.next)
kernel_rfl DEC_grow.st1.fb135 : footRB DEC_grow.st1.s135 DEC_grow.st1.s136 DEC_grow.st1.fR135 = true
kernel_rfl DEC_grow.st1.fc135 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s135.next && Nat.ble DEC_grow.st1.s136.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR135 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa136 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s136 :=
  DEC_grow.st1.fa135.step (stageFoot_ofRF DEC_grow.st1.fh135 DEC_grow.st1.fb135) (incl_of_footW DEC_grow.st1.fb135 DEC_grow.st1.fc135)

def DEC_grow.st1.fR136 : List (Nat × Nat) := [(2672739, 2672740), (3108632, 3108633), (3123795, 3123796), (3256408, 3256409), (3256496, 3256497), (3257810, 3257811), (3257864, 3257865), (3257870, 3257871)]
kernel_rfl DEC_grow.st1.fh136 : DEC_grow.st1.s137.heap = setAll DEC_grow.st1.s136.heap (rangesOf DEC_grow.st1.s137.heap DEC_grow.st1.fR136 ++ freshOf DEC_grow.st1.s137.heap DEC_grow.st1.s136.next DEC_grow.st1.s137.next)
kernel_rfl DEC_grow.st1.fb136 : footRB DEC_grow.st1.s136 DEC_grow.st1.s137 DEC_grow.st1.fR136 = true
kernel_rfl DEC_grow.st1.fc136 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s136.next && Nat.ble DEC_grow.st1.s137.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR136 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa137 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s137 :=
  DEC_grow.st1.fa136.step (stageFoot_ofRF DEC_grow.st1.fh136 DEC_grow.st1.fb136) (incl_of_footW DEC_grow.st1.fb136 DEC_grow.st1.fc136)

def DEC_grow.st1.fR137 : List (Nat × Nat) := [(2672739, 2672740), (3109061, 3109062), (3258564, 3258567), (3258612, 3258617), (3258706, 3258707), (3258831, 3258832), (3258917, 3258918), (3259006, 3259007), (3259049, 3259051), (3259372, 3259373), (3259378, 3259379), (3259384, 3259385), (3259413, 3259415), (3259459, 3259460), (3259503, 3259504), (3259525, 3259527), (3259566, 3259567), (3259598, 3259599), (3259601, 3259611)]
kernel_rfl DEC_grow.st1.fh137 : DEC_grow.st1.s138.heap = setAll DEC_grow.st1.s137.heap (rangesOf DEC_grow.st1.s138.heap DEC_grow.st1.fR137 ++ freshOf DEC_grow.st1.s138.heap DEC_grow.st1.s137.next DEC_grow.st1.s138.next)
kernel_rfl DEC_grow.st1.fb137 : footRB DEC_grow.st1.s137 DEC_grow.st1.s138 DEC_grow.st1.fR137 = true
kernel_rfl DEC_grow.st1.fc137 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s137.next && Nat.ble DEC_grow.st1.s138.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR137 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa138 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s138 :=
  DEC_grow.st1.fa137.step (stageFoot_ofRF DEC_grow.st1.fh137 DEC_grow.st1.fb137) (incl_of_footW DEC_grow.st1.fb137 DEC_grow.st1.fc137)

def DEC_grow.st1.fR138 : List (Nat × Nat) := [(2672744, 2672745), (3110828, 3110829), (3123795, 3123796), (3258526, 3258527), (3258592, 3258593), (3259906, 3259907), (3259960, 3259961), (3259966, 3259967), (3259972, 3259973), (3260226, 3260227), (3260247, 3260248), (3260297, 3260298), (3260320, 3260321), (3260463, 3260464), (3260499, 3260505), (3260539, 3260540)]
kernel_rfl DEC_grow.st1.fh138 : DEC_grow.st1.s139.heap = setAll DEC_grow.st1.s138.heap (rangesOf DEC_grow.st1.s139.heap DEC_grow.st1.fR138 ++ freshOf DEC_grow.st1.s139.heap DEC_grow.st1.s138.next DEC_grow.st1.s139.next)
kernel_rfl DEC_grow.st1.fb138 : footRB DEC_grow.st1.s138 DEC_grow.st1.s139 DEC_grow.st1.fR138 = true
kernel_rfl DEC_grow.st1.fc138 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s138.next && Nat.ble DEC_grow.st1.s139.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR138 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa139 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s139 :=
  DEC_grow.st1.fa138.step (stageFoot_ofRF DEC_grow.st1.fh138 DEC_grow.st1.fb138) (incl_of_footW DEC_grow.st1.fb138 DEC_grow.st1.fc138)

def DEC_grow.st1.fR139 : List (Nat × Nat) := [(2672744, 2672745), (3111257, 3111258), (3260660, 3260663), (3260708, 3260713), (3260802, 3260803), (3261027, 3261028), (3261113, 3261114), (3261202, 3261203), (3261245, 3261247), (3261511, 3261512), (3261568, 3261569), (3261574, 3261575), (3261580, 3261581)]
kernel_rfl DEC_grow.st1.fh139 : DEC_grow.st1.s140.heap = setAll DEC_grow.st1.s139.heap (rangesOf DEC_grow.st1.s140.heap DEC_grow.st1.fR139 ++ freshOf DEC_grow.st1.s140.heap DEC_grow.st1.s139.next DEC_grow.st1.s140.next)
kernel_rfl DEC_grow.st1.fb139 : footRB DEC_grow.st1.s139 DEC_grow.st1.s140 DEC_grow.st1.fR139 = true
kernel_rfl DEC_grow.st1.fc139 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s139.next && Nat.ble DEC_grow.st1.s140.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR139 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa140 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s140 :=
  DEC_grow.st1.fa139.step (stageFoot_ofRF DEC_grow.st1.fh139 DEC_grow.st1.fb139) (incl_of_footW DEC_grow.st1.fb139 DEC_grow.st1.fc139)

def DEC_grow.st1.fR140 : List (Nat × Nat) := [(3123795, 3123796), (3260622, 3260623), (3260688, 3260689), (3262202, 3262203), (3262256, 3262257), (3262262, 3262263), (3262268, 3262269), (3262276, 3262277), (3262290, 3262291), (3262491, 3262492), (3262515, 3262516)]
kernel_rfl DEC_grow.st1.fh140 : DEC_grow.st1.s141.heap = setAll DEC_grow.st1.s140.heap (rangesOf DEC_grow.st1.s141.heap DEC_grow.st1.fR140 ++ freshOf DEC_grow.st1.s141.heap DEC_grow.st1.s140.next DEC_grow.st1.s141.next)
kernel_rfl DEC_grow.st1.fb140 : footRB DEC_grow.st1.s140 DEC_grow.st1.s141 DEC_grow.st1.fR140 = true
kernel_rfl DEC_grow.st1.fc140 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s140.next && Nat.ble DEC_grow.st1.s141.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR140 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa141 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s141 :=
  DEC_grow.st1.fa140.step (stageFoot_ofRF DEC_grow.st1.fh140 DEC_grow.st1.fb140) (incl_of_footW DEC_grow.st1.fb140 DEC_grow.st1.fc140)

def DEC_grow.st1.fR141 : List (Nat × Nat) := [(4841, 4842), (2672756, 2672757), (3113316, 3113317), (3113368, 3113369), (3263020, 3263029), (3263251, 3263252), (3263346, 3263347), (3263432, 3263433), (3263521, 3263522), (3263531, 3263532)]
kernel_rfl DEC_grow.st1.fh141 : DEC_grow.st1.s142.heap = setAll DEC_grow.st1.s141.heap (rangesOf DEC_grow.st1.s142.heap DEC_grow.st1.fR141 ++ freshOf DEC_grow.st1.s142.heap DEC_grow.st1.s141.next DEC_grow.st1.s142.next)
kernel_rfl DEC_grow.st1.fb141 : footRB DEC_grow.st1.s141 DEC_grow.st1.s142 DEC_grow.st1.fR141 = true
kernel_rfl DEC_grow.st1.fc141 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s141.next && Nat.ble DEC_grow.st1.s142.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR141 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa142 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s142 :=
  DEC_grow.st1.fa141.step (stageFoot_ofRF DEC_grow.st1.fh141 DEC_grow.st1.fb141) (incl_of_footW DEC_grow.st1.fb141 DEC_grow.st1.fc141)

def DEC_grow.st1.fR142 : List (Nat × Nat) := [(3123795, 3123796), (3262918, 3262919), (3262957, 3262960), (3262985, 3262986), (3263029, 3263030), (3264489, 3264490), (3264501, 3264502), (3264553, 3264555), (3264556, 3264557), (3264573, 3264574)]
kernel_rfl DEC_grow.st1.fh142 : DEC_grow.st1.s143.heap = setAll DEC_grow.st1.s142.heap (rangesOf DEC_grow.st1.s143.heap DEC_grow.st1.fR142 ++ freshOf DEC_grow.st1.s143.heap DEC_grow.st1.s142.next DEC_grow.st1.s143.next)
kernel_rfl DEC_grow.st1.fb142 : footRB DEC_grow.st1.s142 DEC_grow.st1.s143 DEC_grow.st1.fR142 = true
kernel_rfl DEC_grow.st1.fc142 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s142.next && Nat.ble DEC_grow.st1.s143.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR142 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa143 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s143 :=
  DEC_grow.st1.fa142.step (stageFoot_ofRF DEC_grow.st1.fh142 DEC_grow.st1.fb142) (incl_of_footW DEC_grow.st1.fb142 DEC_grow.st1.fc142)

def DEC_grow.st1.fR143 : List (Nat × Nat) := [(2672765, 2672766), (3115226, 3115227), (3115655, 3115656), (3265398, 3265404), (3265496, 3265497), (3265512, 3265513), (3265530, 3265531)]
kernel_rfl DEC_grow.st1.fh143 : DEC_grow.st1.s144.heap = setAll DEC_grow.st1.s143.heap (rangesOf DEC_grow.st1.s144.heap DEC_grow.st1.fR143 ++ freshOf DEC_grow.st1.s144.heap DEC_grow.st1.s143.next DEC_grow.st1.s144.next)
kernel_rfl DEC_grow.st1.fb143 : footRB DEC_grow.st1.s143 DEC_grow.st1.s144 DEC_grow.st1.fR143 = true
kernel_rfl DEC_grow.st1.fc143 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s143.next && Nat.ble DEC_grow.st1.s144.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR143 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa144 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s144 :=
  DEC_grow.st1.fa143.step (stageFoot_ofRF DEC_grow.st1.fh143 DEC_grow.st1.fb143) (incl_of_footW DEC_grow.st1.fb143 DEC_grow.st1.fc143)

def DEC_grow.st1.fR144 : List (Nat × Nat) := [(3265354, 3265357), (3265404, 3265407), (3265621, 3265622), (3266494, 3266495), (3266551, 3266559)]
kernel_rfl DEC_grow.st1.fh144 : DEC_grow.st1.s145.heap = setAll DEC_grow.st1.s144.heap (rangesOf DEC_grow.st1.s145.heap DEC_grow.st1.fR144 ++ freshOf DEC_grow.st1.s145.heap DEC_grow.st1.s144.next DEC_grow.st1.s145.next)
kernel_rfl DEC_grow.st1.fb144 : footRB DEC_grow.st1.s144 DEC_grow.st1.s145 DEC_grow.st1.fR144 = true
kernel_rfl DEC_grow.st1.fc144 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s144.next && Nat.ble DEC_grow.st1.s145.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR144 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa145 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s145 :=
  DEC_grow.st1.fa144.step (stageFoot_ofRF DEC_grow.st1.fh144 DEC_grow.st1.fb144) (incl_of_footW DEC_grow.st1.fb144 DEC_grow.st1.fc144)

def DEC_grow.st1.fR145 : List (Nat × Nat) := [(2672770, 2672771), (3117422, 3117423), (3123795, 3123796), (3265294, 3265295), (3265382, 3265383), (3266796, 3266797), (3266850, 3266851), (3266856, 3266857), (3267467, 3267468), (3267502, 3267504), (3267505, 3267506)]
kernel_rfl DEC_grow.st1.fh145 : DEC_grow.st1.s146.heap = setAll DEC_grow.st1.s145.heap (rangesOf DEC_grow.st1.s146.heap DEC_grow.st1.fR145 ++ freshOf DEC_grow.st1.s146.heap DEC_grow.st1.s145.next DEC_grow.st1.s146.next)
kernel_rfl DEC_grow.st1.fb145 : footRB DEC_grow.st1.s145 DEC_grow.st1.s146 DEC_grow.st1.fR145 = true
kernel_rfl DEC_grow.st1.fc145 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s145.next && Nat.ble DEC_grow.st1.s146.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR145 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa146 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s146 :=
  DEC_grow.st1.fa145.step (stageFoot_ofRF DEC_grow.st1.fh145 DEC_grow.st1.fb145) (incl_of_footW DEC_grow.st1.fb145 DEC_grow.st1.fc145)

def DEC_grow.st1.fR146 : List (Nat × Nat) := [(2672770, 2672771), (3117851, 3117852), (3267550, 3267553), (3267598, 3267603), (3267692, 3267693), (3267817, 3267818), (3267903, 3267904), (3267992, 3267993), (3268035, 3268037), (3268358, 3268359), (3268364, 3268365), (3268370, 3268371), (3268399, 3268401), (3268445, 3268446), (3268489, 3268490), (3268511, 3268513), (3268552, 3268553), (3268584, 3268585), (3268587, 3268597)]
kernel_rfl DEC_grow.st1.fh146 : DEC_grow.st1.s147.heap = setAll DEC_grow.st1.s146.heap (rangesOf DEC_grow.st1.s147.heap DEC_grow.st1.fR146 ++ freshOf DEC_grow.st1.s147.heap DEC_grow.st1.s146.next DEC_grow.st1.s147.next)
kernel_rfl DEC_grow.st1.fb146 : footRB DEC_grow.st1.s146 DEC_grow.st1.s147 DEC_grow.st1.fR146 = true
kernel_rfl DEC_grow.st1.fc146 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s146.next && Nat.ble DEC_grow.st1.s147.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR146 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa147 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s147 :=
  DEC_grow.st1.fa146.step (stageFoot_ofRF DEC_grow.st1.fh146 DEC_grow.st1.fb146) (incl_of_footW DEC_grow.st1.fb146 DEC_grow.st1.fc146)

def DEC_grow.st1.fR147 : List (Nat × Nat) := [(2672775, 2672776), (3119518, 3119519), (3123795, 3123796), (3267512, 3267513), (3267578, 3267579), (3268892, 3268893), (3268946, 3268947), (3268952, 3268953), (3268958, 3268959), (3269212, 3269213), (3269233, 3269234), (3269283, 3269284), (3269306, 3269307), (3269449, 3269450), (3269478, 3269479), (3269481, 3269491), (3269513, 3269515)]
kernel_rfl DEC_grow.st1.fh147 : DEC_grow.st1.s148.heap = setAll DEC_grow.st1.s147.heap (rangesOf DEC_grow.st1.s148.heap DEC_grow.st1.fR147 ++ freshOf DEC_grow.st1.s148.heap DEC_grow.st1.s147.next DEC_grow.st1.s148.next)
kernel_rfl DEC_grow.st1.fb147 : footRB DEC_grow.st1.s147 DEC_grow.st1.s148 DEC_grow.st1.fR147 = true
kernel_rfl DEC_grow.st1.fc147 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s147.next && Nat.ble DEC_grow.st1.s148.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR147 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa148 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s148 :=
  DEC_grow.st1.fa147.step (stageFoot_ofRF DEC_grow.st1.fh147 DEC_grow.st1.fb147) (incl_of_footW DEC_grow.st1.fb147 DEC_grow.st1.fc147)

def DEC_grow.st1.fR148 : List (Nat × Nat) := [(2672775, 2672776), (3119947, 3119948), (3269646, 3269649), (3269694, 3269699), (3269788, 3269789), (3269913, 3269914), (3269999, 3270000), (3270088, 3270089), (3270131, 3270133), (3270454, 3270455), (3270460, 3270461), (3270466, 3270467), (3270492, 3270497), (3270541, 3270542), (3270580, 3270582)]
kernel_rfl DEC_grow.st1.fh148 : DEC_grow.st1.s149.heap = setAll DEC_grow.st1.s148.heap (rangesOf DEC_grow.st1.s149.heap DEC_grow.st1.fR148 ++ freshOf DEC_grow.st1.s149.heap DEC_grow.st1.s148.next DEC_grow.st1.s149.next)
kernel_rfl DEC_grow.st1.fb148 : footRB DEC_grow.st1.s148 DEC_grow.st1.s149 DEC_grow.st1.fR148 = true
kernel_rfl DEC_grow.st1.fc148 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s148.next && Nat.ble DEC_grow.st1.s149.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR148 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa149 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s149 :=
  DEC_grow.st1.fa148.step (stageFoot_ofRF DEC_grow.st1.fh148 DEC_grow.st1.fb148) (incl_of_footW DEC_grow.st1.fb148 DEC_grow.st1.fc148)

def DEC_grow.st1.fR149 : List (Nat × Nat) := [(3123795, 3123796), (3269608, 3269609), (3269674, 3269675), (3271088, 3271089), (3271142, 3271143), (3271148, 3271149), (3271154, 3271155), (3271408, 3271409), (3271429, 3271430), (3271479, 3271480), (3271497, 3271499), (3271502, 3271503)]
kernel_rfl DEC_grow.st1.fh149 : DEC_grow.st1.s150.heap = setAll DEC_grow.st1.s149.heap (rangesOf DEC_grow.st1.s150.heap DEC_grow.st1.fR149 ++ freshOf DEC_grow.st1.s150.heap DEC_grow.st1.s149.next DEC_grow.st1.s150.next)
kernel_rfl DEC_grow.st1.fb149 : footRB DEC_grow.st1.s149 DEC_grow.st1.s150 DEC_grow.st1.fR149 = true
kernel_rfl DEC_grow.st1.fc149 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s149.next && Nat.ble DEC_grow.st1.s150.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR149 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa150 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s150 :=
  DEC_grow.st1.fa149.step (stageFoot_ofRF DEC_grow.st1.fh149 DEC_grow.st1.fb149) (incl_of_footW DEC_grow.st1.fb149 DEC_grow.st1.fc149)

def DEC_grow.st1.fR150 : List (Nat × Nat) := [(4841, 4842), (2672787, 2672788), (3122002, 3122003), (3122054, 3122055), (3271839, 3271842), (3271902, 3271912), (3272228, 3272229), (3272403, 3272404), (3272471, 3272472), (3272504, 3272505)]
kernel_rfl DEC_grow.st1.fh150 : DEC_grow.st1.s151.heap = setAll DEC_grow.st1.s150.heap (rangesOf DEC_grow.st1.s151.heap DEC_grow.st1.fR150 ++ freshOf DEC_grow.st1.s151.heap DEC_grow.st1.s150.next DEC_grow.st1.s151.next)
kernel_rfl DEC_grow.st1.fb150 : footRB DEC_grow.st1.s150 DEC_grow.st1.s151 DEC_grow.st1.fR150 = true
kernel_rfl DEC_grow.st1.fc150 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s150.next && Nat.ble DEC_grow.st1.s151.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR150 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa151 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s151 :=
  DEC_grow.st1.fa150.step (stageFoot_ofRF DEC_grow.st1.fh150 DEC_grow.st1.fb150) (incl_of_footW DEC_grow.st1.fb150 DEC_grow.st1.fc150)

def DEC_grow.st1.fR151 : List (Nat × Nat) := [(3123795, 3123796), (3271800, 3271801), (3271867, 3271868), (3273456, 3273457), (3273514, 3273515), (3273520, 3273521), (3273526, 3273527), (3273534, 3273535), (3273541, 3273543)]
kernel_rfl DEC_grow.st1.fh151 : DEC_grow.st1.s152.heap = setAll DEC_grow.st1.s151.heap (rangesOf DEC_grow.st1.s152.heap DEC_grow.st1.fR151 ++ freshOf DEC_grow.st1.s152.heap DEC_grow.st1.s151.next DEC_grow.st1.s152.next)
kernel_rfl DEC_grow.st1.fb151 : footRB DEC_grow.st1.s151 DEC_grow.st1.s152 DEC_grow.st1.fR151 = true
kernel_rfl DEC_grow.st1.fc151 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s151.next && Nat.ble DEC_grow.st1.s152.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR151 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa152 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s152 :=
  DEC_grow.st1.fa151.step (stageFoot_ofRF DEC_grow.st1.fh151 DEC_grow.st1.fb151) (incl_of_footW DEC_grow.st1.fb151 DEC_grow.st1.fc151)

def DEC_grow.st1.fR152 : List (Nat × Nat) := []
kernel_rfl DEC_grow.st1.fh152 : DEC_grow.st1.s153.heap = setAll DEC_grow.st1.s152.heap (rangesOf DEC_grow.st1.s153.heap DEC_grow.st1.fR152 ++ freshOf DEC_grow.st1.s153.heap DEC_grow.st1.s152.next DEC_grow.st1.s153.next)
kernel_rfl DEC_grow.st1.fb152 : footRB DEC_grow.st1.s152 DEC_grow.st1.s153 DEC_grow.st1.fR152 = true
kernel_rfl DEC_grow.st1.fc152 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s152.next && Nat.ble DEC_grow.st1.s153.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR152 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa153 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s153 :=
  DEC_grow.st1.fa152.step (stageFoot_ofRF DEC_grow.st1.fh152 DEC_grow.st1.fb152) (incl_of_footW DEC_grow.st1.fb152 DEC_grow.st1.fc152)

end Host.Load.Run.Tpl

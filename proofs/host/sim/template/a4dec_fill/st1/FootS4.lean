import host.sim.template.a4dec_fill.st1.FootS3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_fill.st1.fR128 : List (Nat × Nat) := [(2672713, 2672714), (3102667, 3102668), (3249426, 3249429), (3249474, 3249479), (3249568, 3249569), (3249693, 3249694), (3249779, 3249780), (3249868, 3249869), (3249911, 3249913), (3250234, 3250235), (3250240, 3250241), (3250246, 3250247), (3250275, 3250277), (3250321, 3250322), (3250365, 3250366), (3250387, 3250389), (3250428, 3250429), (3250460, 3250461), (3250463, 3250473), (3250511, 3250512)]
kernel_rfl DEC_fill.st1.fh128 : DEC_fill.st1.s129.heap = setAll DEC_fill.st1.s128.heap (rangesOf DEC_fill.st1.s129.heap DEC_fill.st1.fR128 ++ freshOf DEC_fill.st1.s129.heap DEC_fill.st1.s128.next DEC_fill.st1.s129.next)
kernel_rfl DEC_fill.st1.fb128 : footRB DEC_fill.st1.s128 DEC_fill.st1.s129 DEC_fill.st1.fR128 = true
kernel_rfl DEC_fill.st1.fc128 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s128.next && Nat.ble DEC_fill.st1.s129.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR128 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa129 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s129 :=
  DEC_fill.st1.fa128.step (stageFoot_ofRF DEC_fill.st1.fh128 DEC_fill.st1.fb128) (incl_of_footW DEC_fill.st1.fb128 DEC_fill.st1.fc128)

def DEC_fill.st1.fR129 : List (Nat × Nat) := [(4841, 4842), (2672725, 2672726), (3123795, 3123796), (3249388, 3249389), (3249454, 3249455), (3250768, 3250769), (3250822, 3250823), (3250828, 3250829), (3250834, 3250835), (3251088, 3251089), (3251109, 3251110), (3251159, 3251160), (3251182, 3251183), (3251325, 3251326), (3251366, 3251367), (3251403, 3251405)]
kernel_rfl DEC_fill.st1.fh129 : DEC_fill.st1.s130.heap = setAll DEC_fill.st1.s129.heap (rangesOf DEC_fill.st1.s130.heap DEC_fill.st1.fR129 ++ freshOf DEC_fill.st1.s130.heap DEC_fill.st1.s129.next DEC_fill.st1.s130.next)
kernel_rfl DEC_fill.st1.fb129 : footRB DEC_fill.st1.s129 DEC_fill.st1.s130 DEC_fill.st1.fR129 = true
kernel_rfl DEC_fill.st1.fc129 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s129.next && Nat.ble DEC_fill.st1.s130.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR129 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa130 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s130 :=
  DEC_fill.st1.fa129.step (stageFoot_ofRF DEC_fill.st1.fh129 DEC_fill.st1.fb129) (incl_of_footW DEC_fill.st1.fb129 DEC_fill.st1.fc129)

def DEC_fill.st1.fR130 : List (Nat × Nat) := [(2672725, 2672726), (3104626, 3104627), (3104678, 3104679), (3251523, 3251526), (3251589, 3251596), (3251912, 3251913), (3252322, 3252323), (3252357, 3252358), (3252392, 3252393), (3252417, 3252419), (3252425, 3252432), (3252461, 3252462)]
kernel_rfl DEC_fill.st1.fh130 : DEC_fill.st1.s131.heap = setAll DEC_fill.st1.s130.heap (rangesOf DEC_fill.st1.s131.heap DEC_fill.st1.fR130 ++ freshOf DEC_fill.st1.s131.heap DEC_fill.st1.s130.next DEC_fill.st1.s131.next)
kernel_rfl DEC_fill.st1.fb130 : footRB DEC_fill.st1.s130 DEC_fill.st1.s131 DEC_fill.st1.fR130 = true
kernel_rfl DEC_fill.st1.fc130 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s130.next && Nat.ble DEC_fill.st1.s131.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR130 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa131 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s131 :=
  DEC_fill.st1.fa130.step (stageFoot_ofRF DEC_fill.st1.fh130 DEC_fill.st1.fb130) (incl_of_footW DEC_fill.st1.fb130 DEC_fill.st1.fc130)

def DEC_fill.st1.fR131 : List (Nat × Nat) := [(2672734, 2672735), (3106536, 3106537), (3123795, 3123796), (3251484, 3251485), (3251551, 3251552), (3252944, 3252945), (3253002, 3253003), (3253008, 3253009), (3253014, 3253015), (3253268, 3253269), (3253289, 3253290), (3253339, 3253340), (3253361, 3253363), (3253395, 3253396), (3253398, 3253408)]
kernel_rfl DEC_fill.st1.fh131 : DEC_fill.st1.s132.heap = setAll DEC_fill.st1.s131.heap (rangesOf DEC_fill.st1.s132.heap DEC_fill.st1.fR131 ++ freshOf DEC_fill.st1.s132.heap DEC_fill.st1.s131.next DEC_fill.st1.s132.next)
kernel_rfl DEC_fill.st1.fb131 : footRB DEC_fill.st1.s131 DEC_fill.st1.s132 DEC_fill.st1.fR131 = true
kernel_rfl DEC_fill.st1.fc131 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s131.next && Nat.ble DEC_fill.st1.s132.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR131 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa132 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s132 :=
  DEC_fill.st1.fa131.step (stageFoot_ofRF DEC_fill.st1.fh131 DEC_fill.st1.fb131) (incl_of_footW DEC_fill.st1.fb131 DEC_fill.st1.fc131)

def DEC_fill.st1.fR132 : List (Nat × Nat) := [(2672734, 2672735), (3106965, 3106966), (3253724, 3253727), (3253772, 3253777), (3253866, 3253867), (3253991, 3253992), (3254077, 3254078), (3254166, 3254167), (3254206, 3254211), (3254475, 3254476), (3254489, 3254492), (3254502, 3254512)]
kernel_rfl DEC_fill.st1.fh132 : DEC_fill.st1.s133.heap = setAll DEC_fill.st1.s132.heap (rangesOf DEC_fill.st1.s133.heap DEC_fill.st1.fR132 ++ freshOf DEC_fill.st1.s133.heap DEC_fill.st1.s132.next DEC_fill.st1.s133.next)
kernel_rfl DEC_fill.st1.fb132 : footRB DEC_fill.st1.s132 DEC_fill.st1.s133 DEC_fill.st1.fR132 = true
kernel_rfl DEC_fill.st1.fc132 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s132.next && Nat.ble DEC_fill.st1.s133.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR132 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa133 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s133 :=
  DEC_fill.st1.fa132.step (stageFoot_ofRF DEC_fill.st1.fh132 DEC_fill.st1.fb132) (incl_of_footW DEC_fill.st1.fb132 DEC_fill.st1.fc132)

def DEC_fill.st1.fR133 : List (Nat × Nat) := [(3123795, 3123796), (3253664, 3253665), (3253752, 3253753), (3255066, 3255067), (3255120, 3255121), (3255126, 3255127), (3255132, 3255133), (3255386, 3255387), (3255406, 3255408), (3255428, 3255432)]
kernel_rfl DEC_fill.st1.fh133 : DEC_fill.st1.s134.heap = setAll DEC_fill.st1.s133.heap (rangesOf DEC_fill.st1.s134.heap DEC_fill.st1.fR133 ++ freshOf DEC_fill.st1.s134.heap DEC_fill.st1.s133.next DEC_fill.st1.s134.next)
kernel_rfl DEC_fill.st1.fb133 : footRB DEC_fill.st1.s133 DEC_fill.st1.s134 DEC_fill.st1.fR133 = true
kernel_rfl DEC_fill.st1.fc133 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s133.next && Nat.ble DEC_fill.st1.s134.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR133 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa134 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s134 :=
  DEC_fill.st1.fa133.step (stageFoot_ofRF DEC_fill.st1.fh133 DEC_fill.st1.fb133) (incl_of_footW DEC_fill.st1.fb133 DEC_fill.st1.fc133)

def DEC_fill.st1.fR134 : List (Nat × Nat) := [(2672739, 2672740), (3108632, 3108633), (3109061, 3109062), (3255820, 3255823), (3255868, 3255873), (3255962, 3255963), (3256087, 3256088), (3256173, 3256174), (3256262, 3256263), (3256300, 3256307), (3256346, 3256348), (3256400, 3256401), (3256425, 3256426), (3256482, 3256483)]
kernel_rfl DEC_fill.st1.fh134 : DEC_fill.st1.s135.heap = setAll DEC_fill.st1.s134.heap (rangesOf DEC_fill.st1.s135.heap DEC_fill.st1.fR134 ++ freshOf DEC_fill.st1.s135.heap DEC_fill.st1.s134.next DEC_fill.st1.s135.next)
kernel_rfl DEC_fill.st1.fb134 : footRB DEC_fill.st1.s134 DEC_fill.st1.s135 DEC_fill.st1.fR134 = true
kernel_rfl DEC_fill.st1.fc134 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s134.next && Nat.ble DEC_fill.st1.s135.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR134 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa135 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s135 :=
  DEC_fill.st1.fa134.step (stageFoot_ofRF DEC_fill.st1.fh134 DEC_fill.st1.fb134) (incl_of_footW DEC_fill.st1.fb134 DEC_fill.st1.fc134)

def DEC_fill.st1.fR135 : List (Nat × Nat) := [(3123795, 3123796), (3255782, 3255783), (3255848, 3255849), (3257162, 3257163), (3257216, 3257217), (3257222, 3257223), (3257228, 3257229), (3257236, 3257237), (3257249, 3257251), (3257305, 3257306), (3257333, 3257334), (3257336, 3257346), (3257418, 3257419), (3257436, 3257437)]
kernel_rfl DEC_fill.st1.fh135 : DEC_fill.st1.s136.heap = setAll DEC_fill.st1.s135.heap (rangesOf DEC_fill.st1.s136.heap DEC_fill.st1.fR135 ++ freshOf DEC_fill.st1.s136.heap DEC_fill.st1.s135.next DEC_fill.st1.s136.next)
kernel_rfl DEC_fill.st1.fb135 : footRB DEC_fill.st1.s135 DEC_fill.st1.s136 DEC_fill.st1.fR135 = true
kernel_rfl DEC_fill.st1.fc135 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s135.next && Nat.ble DEC_fill.st1.s136.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR135 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa136 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s136 :=
  DEC_fill.st1.fa135.step (stageFoot_ofRF DEC_fill.st1.fh135 DEC_fill.st1.fb135) (incl_of_footW DEC_fill.st1.fb135 DEC_fill.st1.fc135)

def DEC_fill.st1.fR136 : List (Nat × Nat) := [(2672744, 2672745), (3110828, 3110829), (3111257, 3111258), (3257962, 3257968), (3258058, 3258059), (3258283, 3258284), (3258369, 3258370), (3258385, 3258386)]
kernel_rfl DEC_fill.st1.fh136 : DEC_fill.st1.s137.heap = setAll DEC_fill.st1.s136.heap (rangesOf DEC_fill.st1.s137.heap DEC_fill.st1.fR136 ++ freshOf DEC_fill.st1.s137.heap DEC_fill.st1.s136.next DEC_fill.st1.s137.next)
kernel_rfl DEC_fill.st1.fb136 : footRB DEC_fill.st1.s136 DEC_fill.st1.s137 DEC_fill.st1.fR136 = true
kernel_rfl DEC_fill.st1.fc136 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s136.next && Nat.ble DEC_fill.st1.s137.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR136 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa137 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s137 :=
  DEC_fill.st1.fa136.step (stageFoot_ofRF DEC_fill.st1.fh136 DEC_fill.st1.fb136) (incl_of_footW DEC_fill.st1.fb136 DEC_fill.st1.fc136)

def DEC_fill.st1.fR137 : List (Nat × Nat) := [(3123795, 3123796), (3257878, 3257879), (3257916, 3257919), (3257944, 3257945), (3257968, 3257969), (3259275, 3259276), (3259300, 3259301), (3259368, 3259369), (3259371, 3259381), (3259429, 3259430)]
kernel_rfl DEC_fill.st1.fh137 : DEC_fill.st1.s138.heap = setAll DEC_fill.st1.s137.heap (rangesOf DEC_fill.st1.s138.heap DEC_fill.st1.fR137 ++ freshOf DEC_fill.st1.s138.heap DEC_fill.st1.s137.next DEC_fill.st1.s138.next)
kernel_rfl DEC_fill.st1.fb137 : footRB DEC_fill.st1.s137 DEC_fill.st1.s138 DEC_fill.st1.fR137 = true
kernel_rfl DEC_fill.st1.fc137 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s137.next && Nat.ble DEC_fill.st1.s138.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR137 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa138 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s138 :=
  DEC_fill.st1.fa137.step (stageFoot_ofRF DEC_fill.st1.fh137 DEC_fill.st1.fb137) (incl_of_footW DEC_fill.st1.fb137 DEC_fill.st1.fc137)

def DEC_fill.st1.fR138 : List (Nat × Nat) := [(4841, 4842), (2672756, 2672757), (3113316, 3113317), (3113368, 3113369), (3260272, 3260281), (3260376, 3260377), (3260404, 3260406), (3260407, 3260408), (3260409, 3260410)]
kernel_rfl DEC_fill.st1.fh138 : DEC_fill.st1.s139.heap = setAll DEC_fill.st1.s138.heap (rangesOf DEC_fill.st1.s139.heap DEC_fill.st1.fR138 ++ freshOf DEC_fill.st1.s139.heap DEC_fill.st1.s138.next DEC_fill.st1.s139.next)
kernel_rfl DEC_fill.st1.fb138 : footRB DEC_fill.st1.s138 DEC_fill.st1.s139 DEC_fill.st1.fR138 = true
kernel_rfl DEC_fill.st1.fc138 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s138.next && Nat.ble DEC_fill.st1.s139.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR138 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa139 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s139 :=
  DEC_fill.st1.fa138.step (stageFoot_ofRF DEC_fill.st1.fh138 DEC_fill.st1.fb138) (incl_of_footW DEC_fill.st1.fb138 DEC_fill.st1.fc138)

def DEC_fill.st1.fR139 : List (Nat × Nat) := [(3260213, 3260216), (3260280, 3260286), (3260602, 3260603), (3261047, 3261048), (3261326, 3261327), (3261375, 3261376), (3261410, 3261411)]
kernel_rfl DEC_fill.st1.fh139 : DEC_fill.st1.s140.heap = setAll DEC_fill.st1.s139.heap (rangesOf DEC_fill.st1.s140.heap DEC_fill.st1.fR139 ++ freshOf DEC_fill.st1.s140.heap DEC_fill.st1.s139.next DEC_fill.st1.s140.next)
kernel_rfl DEC_fill.st1.fb139 : footRB DEC_fill.st1.s139 DEC_fill.st1.s140 DEC_fill.st1.fR139 = true
kernel_rfl DEC_fill.st1.fc139 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s139.next && Nat.ble DEC_fill.st1.s140.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR139 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa140 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s140 :=
  DEC_fill.st1.fa139.step (stageFoot_ofRF DEC_fill.st1.fh139 DEC_fill.st1.fb139) (incl_of_footW DEC_fill.st1.fb139 DEC_fill.st1.fc139)

def DEC_fill.st1.fR140 : List (Nat × Nat) := [(2672765, 2672766), (3115226, 3115227), (3123795, 3123796), (3260174, 3260175), (3260241, 3260242)]
kernel_rfl DEC_fill.st1.fh140 : DEC_fill.st1.s141.heap = setAll DEC_fill.st1.s140.heap (rangesOf DEC_fill.st1.s141.heap DEC_fill.st1.fR140 ++ freshOf DEC_fill.st1.s141.heap DEC_fill.st1.s140.next DEC_fill.st1.s141.next)
kernel_rfl DEC_fill.st1.fb140 : footRB DEC_fill.st1.s140 DEC_fill.st1.s141 DEC_fill.st1.fR140 = true
kernel_rfl DEC_fill.st1.fc140 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s140.next && Nat.ble DEC_fill.st1.s141.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR140 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa141 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s141 :=
  DEC_fill.st1.fa140.step (stageFoot_ofRF DEC_fill.st1.fh140 DEC_fill.st1.fb140) (incl_of_footW DEC_fill.st1.fb140 DEC_fill.st1.fc140)

def DEC_fill.st1.fR141 : List (Nat × Nat) := [(2672765, 2672766), (3115655, 3115656), (3262414, 3262417), (3262462, 3262467), (3262556, 3262557), (3262681, 3262682), (3262767, 3262768), (3262856, 3262857), (3262899, 3262901), (3263222, 3263223), (3263228, 3263229), (3263234, 3263235), (3263263, 3263265), (3263309, 3263310), (3263353, 3263354), (3263375, 3263377), (3263416, 3263417), (3263448, 3263449), (3263451, 3263461)]
kernel_rfl DEC_fill.st1.fh141 : DEC_fill.st1.s142.heap = setAll DEC_fill.st1.s141.heap (rangesOf DEC_fill.st1.s142.heap DEC_fill.st1.fR141 ++ freshOf DEC_fill.st1.s142.heap DEC_fill.st1.s141.next DEC_fill.st1.s142.next)
kernel_rfl DEC_fill.st1.fb141 : footRB DEC_fill.st1.s141 DEC_fill.st1.s142 DEC_fill.st1.fR141 = true
kernel_rfl DEC_fill.st1.fc141 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s141.next && Nat.ble DEC_fill.st1.s142.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR141 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa142 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s142 :=
  DEC_fill.st1.fa141.step (stageFoot_ofRF DEC_fill.st1.fh141 DEC_fill.st1.fb141) (incl_of_footW DEC_fill.st1.fb141 DEC_fill.st1.fc141)

def DEC_fill.st1.fR142 : List (Nat × Nat) := [(2672770, 2672771), (3117422, 3117423), (3123795, 3123796), (3262354, 3262355), (3262442, 3262443), (3263856, 3263857), (3263910, 3263911), (3263916, 3263917), (3263922, 3263923), (3264176, 3264177), (3264197, 3264198), (3264247, 3264248), (3264269, 3264271), (3264303, 3264304), (3264306, 3264316), (3264388, 3264389)]
kernel_rfl DEC_fill.st1.fh142 : DEC_fill.st1.s143.heap = setAll DEC_fill.st1.s142.heap (rangesOf DEC_fill.st1.s143.heap DEC_fill.st1.fR142 ++ freshOf DEC_fill.st1.s143.heap DEC_fill.st1.s142.next DEC_fill.st1.s143.next)
kernel_rfl DEC_fill.st1.fb142 : footRB DEC_fill.st1.s142 DEC_fill.st1.s143 DEC_fill.st1.fR142 = true
kernel_rfl DEC_fill.st1.fc142 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s142.next && Nat.ble DEC_fill.st1.s143.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR142 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa143 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s143 :=
  DEC_fill.st1.fa142.step (stageFoot_ofRF DEC_fill.st1.fh142 DEC_fill.st1.fb142) (incl_of_footW DEC_fill.st1.fb142 DEC_fill.st1.fc142)

def DEC_fill.st1.fR143 : List (Nat × Nat) := [(2672770, 2672771), (3117851, 3117852), (3264610, 3264613), (3264658, 3264663), (3264752, 3264753), (3264877, 3264878), (3264963, 3264964), (3265052, 3265053), (3265092, 3265097), (3265361, 3265362), (3265375, 3265378), (3265418, 3265419), (3265424, 3265425), (3265430, 3265431)]
kernel_rfl DEC_fill.st1.fh143 : DEC_fill.st1.s144.heap = setAll DEC_fill.st1.s143.heap (rangesOf DEC_fill.st1.s144.heap DEC_fill.st1.fR143 ++ freshOf DEC_fill.st1.s144.heap DEC_fill.st1.s143.next DEC_fill.st1.s144.next)
kernel_rfl DEC_fill.st1.fb143 : footRB DEC_fill.st1.s143 DEC_fill.st1.s144 DEC_fill.st1.fR143 = true
kernel_rfl DEC_fill.st1.fc143 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s143.next && Nat.ble DEC_fill.st1.s144.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR143 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa144 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s144 :=
  DEC_fill.st1.fa143.step (stageFoot_ofRF DEC_fill.st1.fh143 DEC_fill.st1.fb143) (incl_of_footW DEC_fill.st1.fb143 DEC_fill.st1.fc143)

def DEC_fill.st1.fR144 : List (Nat × Nat) := [(3123795, 3123796), (3264572, 3264573), (3264638, 3264639), (3265952, 3265953), (3266006, 3266007), (3266012, 3266013), (3266018, 3266019), (3266272, 3266273), (3266293, 3266294), (3266343, 3266344), (3266365, 3266367)]
kernel_rfl DEC_fill.st1.fh144 : DEC_fill.st1.s145.heap = setAll DEC_fill.st1.s144.heap (rangesOf DEC_fill.st1.s145.heap DEC_fill.st1.fR144 ++ freshOf DEC_fill.st1.s145.heap DEC_fill.st1.s144.next DEC_fill.st1.s145.next)
kernel_rfl DEC_fill.st1.fb144 : footRB DEC_fill.st1.s144 DEC_fill.st1.s145 DEC_fill.st1.fR144 = true
kernel_rfl DEC_fill.st1.fc144 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s144.next && Nat.ble DEC_fill.st1.s145.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR144 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa145 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s145 :=
  DEC_fill.st1.fa144.step (stageFoot_ofRF DEC_fill.st1.fh144 DEC_fill.st1.fb144) (incl_of_footW DEC_fill.st1.fb144 DEC_fill.st1.fc144)

def DEC_fill.st1.fR145 : List (Nat × Nat) := [(2672775, 2672776), (3119518, 3119519), (3119947, 3119948), (3266706, 3266709), (3266754, 3266759), (3266848, 3266849), (3266973, 3266974), (3267059, 3267060), (3267148, 3267149), (3267186, 3267193), (3267233, 3267234), (3267286, 3267287), (3267445, 3267449)]
kernel_rfl DEC_fill.st1.fh145 : DEC_fill.st1.s146.heap = setAll DEC_fill.st1.s145.heap (rangesOf DEC_fill.st1.s146.heap DEC_fill.st1.fR145 ++ freshOf DEC_fill.st1.s146.heap DEC_fill.st1.s145.next DEC_fill.st1.s146.next)
kernel_rfl DEC_fill.st1.fb145 : footRB DEC_fill.st1.s145 DEC_fill.st1.s146 DEC_fill.st1.fR145 = true
kernel_rfl DEC_fill.st1.fc145 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s145.next && Nat.ble DEC_fill.st1.s146.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR145 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa146 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s146 :=
  DEC_fill.st1.fa145.step (stageFoot_ofRF DEC_fill.st1.fh145 DEC_fill.st1.fb145) (incl_of_footW DEC_fill.st1.fb145 DEC_fill.st1.fc145)

def DEC_fill.st1.fR146 : List (Nat × Nat) := [(3123795, 3123796), (3266668, 3266669), (3266734, 3266735), (3268148, 3268149), (3268202, 3268203), (3268208, 3268209), (3268214, 3268215), (3268222, 3268223), (3268235, 3268237), (3268291, 3268292), (3268319, 3268320), (3268322, 3268332), (3268380, 3268381)]
kernel_rfl DEC_fill.st1.fh146 : DEC_fill.st1.s147.heap = setAll DEC_fill.st1.s146.heap (rangesOf DEC_fill.st1.s147.heap DEC_fill.st1.fR146 ++ freshOf DEC_fill.st1.s147.heap DEC_fill.st1.s146.next DEC_fill.st1.s147.next)
kernel_rfl DEC_fill.st1.fb146 : footRB DEC_fill.st1.s146 DEC_fill.st1.s147 DEC_fill.st1.fR146 = true
kernel_rfl DEC_fill.st1.fc146 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s146.next && Nat.ble DEC_fill.st1.s147.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR146 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa147 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s147 :=
  DEC_fill.st1.fa146.step (stageFoot_ofRF DEC_fill.st1.fh146 DEC_fill.st1.fb146) (incl_of_footW DEC_fill.st1.fb146 DEC_fill.st1.fc146)

def DEC_fill.st1.fR147 : List (Nat × Nat) := [(4841, 4842), (2672787, 2672788), (3122002, 3122003), (3122054, 3122055), (3268899, 3268900), (3268962, 3268972), (3269193, 3269194), (3269288, 3269289), (3269301, 3269302), (3269353, 3269355), (3269356, 3269357)]
kernel_rfl DEC_fill.st1.fh147 : DEC_fill.st1.s148.heap = setAll DEC_fill.st1.s147.heap (rangesOf DEC_fill.st1.s148.heap DEC_fill.st1.fR147 ++ freshOf DEC_fill.st1.s148.heap DEC_fill.st1.s147.next DEC_fill.st1.s148.next)
kernel_rfl DEC_fill.st1.fb147 : footRB DEC_fill.st1.s147 DEC_fill.st1.s148 DEC_fill.st1.fR147 = true
kernel_rfl DEC_fill.st1.fc147 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s147.next && Nat.ble DEC_fill.st1.s148.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR147 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa148 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s148 :=
  DEC_fill.st1.fa147.step (stageFoot_ofRF DEC_fill.st1.fh147 DEC_fill.st1.fb147) (incl_of_footW DEC_fill.st1.fb147 DEC_fill.st1.fc147)

def DEC_fill.st1.fR148 : List (Nat × Nat) := [(3123795, 3123796), (3268860, 3268861), (3268900, 3268902), (3268927, 3268928), (3270320, 3270321), (3270373, 3270374), (3270378, 3270379)]
kernel_rfl DEC_fill.st1.fh148 : DEC_fill.st1.s149.heap = setAll DEC_fill.st1.s148.heap (rangesOf DEC_fill.st1.s149.heap DEC_fill.st1.fR148 ++ freshOf DEC_fill.st1.s149.heap DEC_fill.st1.s148.next DEC_fill.st1.s149.next)
kernel_rfl DEC_fill.st1.fb148 : footRB DEC_fill.st1.s148 DEC_fill.st1.s149 DEC_fill.st1.fR148 = true
kernel_rfl DEC_fill.st1.fc148 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s148.next && Nat.ble DEC_fill.st1.s149.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR148 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa149 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s149 :=
  DEC_fill.st1.fa148.step (stageFoot_ofRF DEC_fill.st1.fh148 DEC_fill.st1.fb148) (incl_of_footW DEC_fill.st1.fb148 DEC_fill.st1.fc148)

def DEC_fill.st1.fR149 : List (Nat × Nat) := []
kernel_rfl DEC_fill.st1.fh149 : DEC_fill.st1.s150.heap = setAll DEC_fill.st1.s149.heap (rangesOf DEC_fill.st1.s150.heap DEC_fill.st1.fR149 ++ freshOf DEC_fill.st1.s150.heap DEC_fill.st1.s149.next DEC_fill.st1.s150.next)
kernel_rfl DEC_fill.st1.fb149 : footRB DEC_fill.st1.s149 DEC_fill.st1.s150 DEC_fill.st1.fR149 = true
kernel_rfl DEC_fill.st1.fc149 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s149.next && Nat.ble DEC_fill.st1.s150.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR149 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa150 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s150 :=
  DEC_fill.st1.fa149.step (stageFoot_ofRF DEC_fill.st1.fh149 DEC_fill.st1.fb149) (incl_of_footW DEC_fill.st1.fb149 DEC_fill.st1.fc149)

end Host.Load.Run.Tpl

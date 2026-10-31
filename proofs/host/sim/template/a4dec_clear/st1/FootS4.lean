import host.sim.template.a4dec_clear.st1.FootS3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clear.st1.fR128 : List (Nat × Nat) := [(2672713, 2672714), (3102667, 3102668), (3249427, 3249430), (3249475, 3249480), (3249569, 3249570), (3249694, 3249695), (3249780, 3249781), (3249869, 3249870), (3249912, 3249914), (3250235, 3250236), (3250241, 3250242), (3250247, 3250248), (3250276, 3250278), (3250322, 3250323), (3250366, 3250367), (3250388, 3250390), (3250429, 3250430), (3250461, 3250462), (3250464, 3250474), (3250512, 3250513)]
kernel_rfl DEC_clear.st1.fh128 : DEC_clear.st1.s129.heap = setAll DEC_clear.st1.s128.heap (rangesOf DEC_clear.st1.s129.heap DEC_clear.st1.fR128 ++ freshOf DEC_clear.st1.s129.heap DEC_clear.st1.s128.next DEC_clear.st1.s129.next)
kernel_rfl DEC_clear.st1.fb128 : footRB DEC_clear.st1.s128 DEC_clear.st1.s129 DEC_clear.st1.fR128 = true
kernel_rfl DEC_clear.st1.fc128 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s128.next && Nat.ble DEC_clear.st1.s129.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR128 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa129 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s129 :=
  DEC_clear.st1.fa128.step (stageFoot_ofRF DEC_clear.st1.fh128 DEC_clear.st1.fb128) (incl_of_footW DEC_clear.st1.fb128 DEC_clear.st1.fc128)

def DEC_clear.st1.fR129 : List (Nat × Nat) := [(4841, 4842), (2672725, 2672726), (3123796, 3123797), (3249389, 3249390), (3249455, 3249456), (3250769, 3250770), (3250823, 3250824), (3250829, 3250830), (3250835, 3250836), (3251089, 3251090), (3251110, 3251111), (3251160, 3251161), (3251183, 3251184), (3251326, 3251327), (3251367, 3251368), (3251404, 3251406)]
kernel_rfl DEC_clear.st1.fh129 : DEC_clear.st1.s130.heap = setAll DEC_clear.st1.s129.heap (rangesOf DEC_clear.st1.s130.heap DEC_clear.st1.fR129 ++ freshOf DEC_clear.st1.s130.heap DEC_clear.st1.s129.next DEC_clear.st1.s130.next)
kernel_rfl DEC_clear.st1.fb129 : footRB DEC_clear.st1.s129 DEC_clear.st1.s130 DEC_clear.st1.fR129 = true
kernel_rfl DEC_clear.st1.fc129 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s129.next && Nat.ble DEC_clear.st1.s130.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR129 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa130 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s130 :=
  DEC_clear.st1.fa129.step (stageFoot_ofRF DEC_clear.st1.fh129 DEC_clear.st1.fb129) (incl_of_footW DEC_clear.st1.fb129 DEC_clear.st1.fc129)

def DEC_clear.st1.fR130 : List (Nat × Nat) := [(2672725, 2672726), (3104626, 3104627), (3104678, 3104679), (3251524, 3251527), (3251590, 3251597), (3251913, 3251914), (3252323, 3252324), (3252358, 3252359), (3252393, 3252394), (3252418, 3252420), (3252426, 3252433), (3252462, 3252463)]
kernel_rfl DEC_clear.st1.fh130 : DEC_clear.st1.s131.heap = setAll DEC_clear.st1.s130.heap (rangesOf DEC_clear.st1.s131.heap DEC_clear.st1.fR130 ++ freshOf DEC_clear.st1.s131.heap DEC_clear.st1.s130.next DEC_clear.st1.s131.next)
kernel_rfl DEC_clear.st1.fb130 : footRB DEC_clear.st1.s130 DEC_clear.st1.s131 DEC_clear.st1.fR130 = true
kernel_rfl DEC_clear.st1.fc130 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s130.next && Nat.ble DEC_clear.st1.s131.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR130 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa131 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s131 :=
  DEC_clear.st1.fa130.step (stageFoot_ofRF DEC_clear.st1.fh130 DEC_clear.st1.fb130) (incl_of_footW DEC_clear.st1.fb130 DEC_clear.st1.fc130)

def DEC_clear.st1.fR131 : List (Nat × Nat) := [(2672734, 2672735), (3106536, 3106537), (3123796, 3123797), (3251485, 3251486), (3251552, 3251553), (3252945, 3252946), (3253003, 3253004), (3253009, 3253010), (3253015, 3253016), (3253269, 3253270), (3253290, 3253291), (3253340, 3253341), (3253362, 3253364), (3253396, 3253397), (3253399, 3253409)]
kernel_rfl DEC_clear.st1.fh131 : DEC_clear.st1.s132.heap = setAll DEC_clear.st1.s131.heap (rangesOf DEC_clear.st1.s132.heap DEC_clear.st1.fR131 ++ freshOf DEC_clear.st1.s132.heap DEC_clear.st1.s131.next DEC_clear.st1.s132.next)
kernel_rfl DEC_clear.st1.fb131 : footRB DEC_clear.st1.s131 DEC_clear.st1.s132 DEC_clear.st1.fR131 = true
kernel_rfl DEC_clear.st1.fc131 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s131.next && Nat.ble DEC_clear.st1.s132.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR131 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa132 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s132 :=
  DEC_clear.st1.fa131.step (stageFoot_ofRF DEC_clear.st1.fh131 DEC_clear.st1.fb131) (incl_of_footW DEC_clear.st1.fb131 DEC_clear.st1.fc131)

def DEC_clear.st1.fR132 : List (Nat × Nat) := [(2672734, 2672735), (3106965, 3106966), (3253725, 3253728), (3253773, 3253778), (3253867, 3253868), (3253992, 3253993), (3254078, 3254079), (3254167, 3254168), (3254207, 3254212), (3254476, 3254477), (3254490, 3254493), (3254503, 3254513)]
kernel_rfl DEC_clear.st1.fh132 : DEC_clear.st1.s133.heap = setAll DEC_clear.st1.s132.heap (rangesOf DEC_clear.st1.s133.heap DEC_clear.st1.fR132 ++ freshOf DEC_clear.st1.s133.heap DEC_clear.st1.s132.next DEC_clear.st1.s133.next)
kernel_rfl DEC_clear.st1.fb132 : footRB DEC_clear.st1.s132 DEC_clear.st1.s133 DEC_clear.st1.fR132 = true
kernel_rfl DEC_clear.st1.fc132 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s132.next && Nat.ble DEC_clear.st1.s133.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR132 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa133 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s133 :=
  DEC_clear.st1.fa132.step (stageFoot_ofRF DEC_clear.st1.fh132 DEC_clear.st1.fb132) (incl_of_footW DEC_clear.st1.fb132 DEC_clear.st1.fc132)

def DEC_clear.st1.fR133 : List (Nat × Nat) := [(3123796, 3123797), (3253665, 3253666), (3253753, 3253754), (3255067, 3255068), (3255121, 3255122), (3255127, 3255128), (3255133, 3255134), (3255387, 3255388), (3255407, 3255409), (3255429, 3255433)]
kernel_rfl DEC_clear.st1.fh133 : DEC_clear.st1.s134.heap = setAll DEC_clear.st1.s133.heap (rangesOf DEC_clear.st1.s134.heap DEC_clear.st1.fR133 ++ freshOf DEC_clear.st1.s134.heap DEC_clear.st1.s133.next DEC_clear.st1.s134.next)
kernel_rfl DEC_clear.st1.fb133 : footRB DEC_clear.st1.s133 DEC_clear.st1.s134 DEC_clear.st1.fR133 = true
kernel_rfl DEC_clear.st1.fc133 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s133.next && Nat.ble DEC_clear.st1.s134.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR133 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa134 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s134 :=
  DEC_clear.st1.fa133.step (stageFoot_ofRF DEC_clear.st1.fh133 DEC_clear.st1.fb133) (incl_of_footW DEC_clear.st1.fb133 DEC_clear.st1.fc133)

def DEC_clear.st1.fR134 : List (Nat × Nat) := [(2672739, 2672740), (3108632, 3108633), (3109061, 3109062), (3255821, 3255824), (3255869, 3255874), (3255963, 3255964), (3256088, 3256089), (3256174, 3256175), (3256263, 3256264), (3256301, 3256308), (3256347, 3256349), (3256401, 3256402), (3256426, 3256427), (3256483, 3256484)]
kernel_rfl DEC_clear.st1.fh134 : DEC_clear.st1.s135.heap = setAll DEC_clear.st1.s134.heap (rangesOf DEC_clear.st1.s135.heap DEC_clear.st1.fR134 ++ freshOf DEC_clear.st1.s135.heap DEC_clear.st1.s134.next DEC_clear.st1.s135.next)
kernel_rfl DEC_clear.st1.fb134 : footRB DEC_clear.st1.s134 DEC_clear.st1.s135 DEC_clear.st1.fR134 = true
kernel_rfl DEC_clear.st1.fc134 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s134.next && Nat.ble DEC_clear.st1.s135.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR134 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa135 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s135 :=
  DEC_clear.st1.fa134.step (stageFoot_ofRF DEC_clear.st1.fh134 DEC_clear.st1.fb134) (incl_of_footW DEC_clear.st1.fb134 DEC_clear.st1.fc134)

def DEC_clear.st1.fR135 : List (Nat × Nat) := [(3123796, 3123797), (3255783, 3255784), (3255849, 3255850), (3257163, 3257164), (3257217, 3257218), (3257223, 3257224), (3257229, 3257230), (3257237, 3257238), (3257250, 3257252), (3257306, 3257307), (3257334, 3257335), (3257337, 3257347), (3257419, 3257420), (3257437, 3257438)]
kernel_rfl DEC_clear.st1.fh135 : DEC_clear.st1.s136.heap = setAll DEC_clear.st1.s135.heap (rangesOf DEC_clear.st1.s136.heap DEC_clear.st1.fR135 ++ freshOf DEC_clear.st1.s136.heap DEC_clear.st1.s135.next DEC_clear.st1.s136.next)
kernel_rfl DEC_clear.st1.fb135 : footRB DEC_clear.st1.s135 DEC_clear.st1.s136 DEC_clear.st1.fR135 = true
kernel_rfl DEC_clear.st1.fc135 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s135.next && Nat.ble DEC_clear.st1.s136.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR135 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa136 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s136 :=
  DEC_clear.st1.fa135.step (stageFoot_ofRF DEC_clear.st1.fh135 DEC_clear.st1.fb135) (incl_of_footW DEC_clear.st1.fb135 DEC_clear.st1.fc135)

def DEC_clear.st1.fR136 : List (Nat × Nat) := [(2672744, 2672745), (3110828, 3110829), (3111257, 3111258), (3257963, 3257969), (3258059, 3258060), (3258284, 3258285), (3258370, 3258371), (3258386, 3258387)]
kernel_rfl DEC_clear.st1.fh136 : DEC_clear.st1.s137.heap = setAll DEC_clear.st1.s136.heap (rangesOf DEC_clear.st1.s137.heap DEC_clear.st1.fR136 ++ freshOf DEC_clear.st1.s137.heap DEC_clear.st1.s136.next DEC_clear.st1.s137.next)
kernel_rfl DEC_clear.st1.fb136 : footRB DEC_clear.st1.s136 DEC_clear.st1.s137 DEC_clear.st1.fR136 = true
kernel_rfl DEC_clear.st1.fc136 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s136.next && Nat.ble DEC_clear.st1.s137.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR136 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa137 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s137 :=
  DEC_clear.st1.fa136.step (stageFoot_ofRF DEC_clear.st1.fh136 DEC_clear.st1.fb136) (incl_of_footW DEC_clear.st1.fb136 DEC_clear.st1.fc136)

def DEC_clear.st1.fR137 : List (Nat × Nat) := [(3123796, 3123797), (3257879, 3257880), (3257917, 3257920), (3257945, 3257946), (3257969, 3257970), (3259276, 3259277), (3259301, 3259302), (3259369, 3259370), (3259372, 3259382), (3259430, 3259431)]
kernel_rfl DEC_clear.st1.fh137 : DEC_clear.st1.s138.heap = setAll DEC_clear.st1.s137.heap (rangesOf DEC_clear.st1.s138.heap DEC_clear.st1.fR137 ++ freshOf DEC_clear.st1.s138.heap DEC_clear.st1.s137.next DEC_clear.st1.s138.next)
kernel_rfl DEC_clear.st1.fb137 : footRB DEC_clear.st1.s137 DEC_clear.st1.s138 DEC_clear.st1.fR137 = true
kernel_rfl DEC_clear.st1.fc137 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s137.next && Nat.ble DEC_clear.st1.s138.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR137 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa138 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s138 :=
  DEC_clear.st1.fa137.step (stageFoot_ofRF DEC_clear.st1.fh137 DEC_clear.st1.fb137) (incl_of_footW DEC_clear.st1.fb137 DEC_clear.st1.fc137)

def DEC_clear.st1.fR138 : List (Nat × Nat) := [(4841, 4842), (2672756, 2672757), (3113316, 3113317), (3113368, 3113369), (3260273, 3260282), (3260377, 3260378), (3260405, 3260407), (3260408, 3260409), (3260410, 3260411)]
kernel_rfl DEC_clear.st1.fh138 : DEC_clear.st1.s139.heap = setAll DEC_clear.st1.s138.heap (rangesOf DEC_clear.st1.s139.heap DEC_clear.st1.fR138 ++ freshOf DEC_clear.st1.s139.heap DEC_clear.st1.s138.next DEC_clear.st1.s139.next)
kernel_rfl DEC_clear.st1.fb138 : footRB DEC_clear.st1.s138 DEC_clear.st1.s139 DEC_clear.st1.fR138 = true
kernel_rfl DEC_clear.st1.fc138 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s138.next && Nat.ble DEC_clear.st1.s139.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR138 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa139 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s139 :=
  DEC_clear.st1.fa138.step (stageFoot_ofRF DEC_clear.st1.fh138 DEC_clear.st1.fb138) (incl_of_footW DEC_clear.st1.fb138 DEC_clear.st1.fc138)

def DEC_clear.st1.fR139 : List (Nat × Nat) := [(3260214, 3260217), (3260281, 3260287), (3260603, 3260604), (3261048, 3261049), (3261327, 3261328), (3261376, 3261377), (3261411, 3261412)]
kernel_rfl DEC_clear.st1.fh139 : DEC_clear.st1.s140.heap = setAll DEC_clear.st1.s139.heap (rangesOf DEC_clear.st1.s140.heap DEC_clear.st1.fR139 ++ freshOf DEC_clear.st1.s140.heap DEC_clear.st1.s139.next DEC_clear.st1.s140.next)
kernel_rfl DEC_clear.st1.fb139 : footRB DEC_clear.st1.s139 DEC_clear.st1.s140 DEC_clear.st1.fR139 = true
kernel_rfl DEC_clear.st1.fc139 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s139.next && Nat.ble DEC_clear.st1.s140.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR139 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa140 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s140 :=
  DEC_clear.st1.fa139.step (stageFoot_ofRF DEC_clear.st1.fh139 DEC_clear.st1.fb139) (incl_of_footW DEC_clear.st1.fb139 DEC_clear.st1.fc139)

def DEC_clear.st1.fR140 : List (Nat × Nat) := [(2672765, 2672766), (3115226, 3115227), (3123796, 3123797), (3260175, 3260176), (3260242, 3260243)]
kernel_rfl DEC_clear.st1.fh140 : DEC_clear.st1.s141.heap = setAll DEC_clear.st1.s140.heap (rangesOf DEC_clear.st1.s141.heap DEC_clear.st1.fR140 ++ freshOf DEC_clear.st1.s141.heap DEC_clear.st1.s140.next DEC_clear.st1.s141.next)
kernel_rfl DEC_clear.st1.fb140 : footRB DEC_clear.st1.s140 DEC_clear.st1.s141 DEC_clear.st1.fR140 = true
kernel_rfl DEC_clear.st1.fc140 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s140.next && Nat.ble DEC_clear.st1.s141.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR140 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa141 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s141 :=
  DEC_clear.st1.fa140.step (stageFoot_ofRF DEC_clear.st1.fh140 DEC_clear.st1.fb140) (incl_of_footW DEC_clear.st1.fb140 DEC_clear.st1.fc140)

def DEC_clear.st1.fR141 : List (Nat × Nat) := [(2672765, 2672766), (3115655, 3115656), (3262415, 3262418), (3262463, 3262468), (3262557, 3262558), (3262682, 3262683), (3262768, 3262769), (3262857, 3262858), (3262900, 3262902), (3263223, 3263224), (3263229, 3263230), (3263235, 3263236), (3263264, 3263266), (3263310, 3263311), (3263354, 3263355), (3263376, 3263378), (3263417, 3263418), (3263449, 3263450), (3263452, 3263462)]
kernel_rfl DEC_clear.st1.fh141 : DEC_clear.st1.s142.heap = setAll DEC_clear.st1.s141.heap (rangesOf DEC_clear.st1.s142.heap DEC_clear.st1.fR141 ++ freshOf DEC_clear.st1.s142.heap DEC_clear.st1.s141.next DEC_clear.st1.s142.next)
kernel_rfl DEC_clear.st1.fb141 : footRB DEC_clear.st1.s141 DEC_clear.st1.s142 DEC_clear.st1.fR141 = true
kernel_rfl DEC_clear.st1.fc141 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s141.next && Nat.ble DEC_clear.st1.s142.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR141 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa142 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s142 :=
  DEC_clear.st1.fa141.step (stageFoot_ofRF DEC_clear.st1.fh141 DEC_clear.st1.fb141) (incl_of_footW DEC_clear.st1.fb141 DEC_clear.st1.fc141)

def DEC_clear.st1.fR142 : List (Nat × Nat) := [(2672770, 2672771), (3117422, 3117423), (3123796, 3123797), (3262355, 3262356), (3262443, 3262444), (3263857, 3263858), (3263911, 3263912), (3263917, 3263918), (3263923, 3263924), (3264177, 3264178), (3264198, 3264199), (3264248, 3264249), (3264270, 3264272), (3264304, 3264305), (3264307, 3264317), (3264389, 3264390)]
kernel_rfl DEC_clear.st1.fh142 : DEC_clear.st1.s143.heap = setAll DEC_clear.st1.s142.heap (rangesOf DEC_clear.st1.s143.heap DEC_clear.st1.fR142 ++ freshOf DEC_clear.st1.s143.heap DEC_clear.st1.s142.next DEC_clear.st1.s143.next)
kernel_rfl DEC_clear.st1.fb142 : footRB DEC_clear.st1.s142 DEC_clear.st1.s143 DEC_clear.st1.fR142 = true
kernel_rfl DEC_clear.st1.fc142 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s142.next && Nat.ble DEC_clear.st1.s143.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR142 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa143 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s143 :=
  DEC_clear.st1.fa142.step (stageFoot_ofRF DEC_clear.st1.fh142 DEC_clear.st1.fb142) (incl_of_footW DEC_clear.st1.fb142 DEC_clear.st1.fc142)

def DEC_clear.st1.fR143 : List (Nat × Nat) := [(2672770, 2672771), (3117851, 3117852), (3264611, 3264614), (3264659, 3264664), (3264753, 3264754), (3264878, 3264879), (3264964, 3264965), (3265053, 3265054), (3265093, 3265098), (3265362, 3265363), (3265376, 3265379), (3265419, 3265420), (3265425, 3265426), (3265431, 3265432)]
kernel_rfl DEC_clear.st1.fh143 : DEC_clear.st1.s144.heap = setAll DEC_clear.st1.s143.heap (rangesOf DEC_clear.st1.s144.heap DEC_clear.st1.fR143 ++ freshOf DEC_clear.st1.s144.heap DEC_clear.st1.s143.next DEC_clear.st1.s144.next)
kernel_rfl DEC_clear.st1.fb143 : footRB DEC_clear.st1.s143 DEC_clear.st1.s144 DEC_clear.st1.fR143 = true
kernel_rfl DEC_clear.st1.fc143 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s143.next && Nat.ble DEC_clear.st1.s144.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR143 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa144 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s144 :=
  DEC_clear.st1.fa143.step (stageFoot_ofRF DEC_clear.st1.fh143 DEC_clear.st1.fb143) (incl_of_footW DEC_clear.st1.fb143 DEC_clear.st1.fc143)

def DEC_clear.st1.fR144 : List (Nat × Nat) := [(3123796, 3123797), (3264573, 3264574), (3264639, 3264640), (3265953, 3265954), (3266007, 3266008), (3266013, 3266014), (3266019, 3266020), (3266273, 3266274), (3266294, 3266295), (3266344, 3266345), (3266366, 3266368)]
kernel_rfl DEC_clear.st1.fh144 : DEC_clear.st1.s145.heap = setAll DEC_clear.st1.s144.heap (rangesOf DEC_clear.st1.s145.heap DEC_clear.st1.fR144 ++ freshOf DEC_clear.st1.s145.heap DEC_clear.st1.s144.next DEC_clear.st1.s145.next)
kernel_rfl DEC_clear.st1.fb144 : footRB DEC_clear.st1.s144 DEC_clear.st1.s145 DEC_clear.st1.fR144 = true
kernel_rfl DEC_clear.st1.fc144 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s144.next && Nat.ble DEC_clear.st1.s145.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR144 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa145 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s145 :=
  DEC_clear.st1.fa144.step (stageFoot_ofRF DEC_clear.st1.fh144 DEC_clear.st1.fb144) (incl_of_footW DEC_clear.st1.fb144 DEC_clear.st1.fc144)

def DEC_clear.st1.fR145 : List (Nat × Nat) := [(2672775, 2672776), (3119518, 3119519), (3119947, 3119948), (3266707, 3266710), (3266755, 3266760), (3266849, 3266850), (3266974, 3266975), (3267060, 3267061), (3267149, 3267150), (3267187, 3267194), (3267234, 3267235), (3267287, 3267288), (3267446, 3267450)]
kernel_rfl DEC_clear.st1.fh145 : DEC_clear.st1.s146.heap = setAll DEC_clear.st1.s145.heap (rangesOf DEC_clear.st1.s146.heap DEC_clear.st1.fR145 ++ freshOf DEC_clear.st1.s146.heap DEC_clear.st1.s145.next DEC_clear.st1.s146.next)
kernel_rfl DEC_clear.st1.fb145 : footRB DEC_clear.st1.s145 DEC_clear.st1.s146 DEC_clear.st1.fR145 = true
kernel_rfl DEC_clear.st1.fc145 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s145.next && Nat.ble DEC_clear.st1.s146.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR145 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa146 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s146 :=
  DEC_clear.st1.fa145.step (stageFoot_ofRF DEC_clear.st1.fh145 DEC_clear.st1.fb145) (incl_of_footW DEC_clear.st1.fb145 DEC_clear.st1.fc145)

def DEC_clear.st1.fR146 : List (Nat × Nat) := [(3123796, 3123797), (3266669, 3266670), (3266735, 3266736), (3268149, 3268150), (3268203, 3268204), (3268209, 3268210), (3268215, 3268216), (3268223, 3268224), (3268236, 3268238), (3268292, 3268293), (3268320, 3268321), (3268323, 3268333), (3268381, 3268382)]
kernel_rfl DEC_clear.st1.fh146 : DEC_clear.st1.s147.heap = setAll DEC_clear.st1.s146.heap (rangesOf DEC_clear.st1.s147.heap DEC_clear.st1.fR146 ++ freshOf DEC_clear.st1.s147.heap DEC_clear.st1.s146.next DEC_clear.st1.s147.next)
kernel_rfl DEC_clear.st1.fb146 : footRB DEC_clear.st1.s146 DEC_clear.st1.s147 DEC_clear.st1.fR146 = true
kernel_rfl DEC_clear.st1.fc146 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s146.next && Nat.ble DEC_clear.st1.s147.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR146 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa147 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s147 :=
  DEC_clear.st1.fa146.step (stageFoot_ofRF DEC_clear.st1.fh146 DEC_clear.st1.fb146) (incl_of_footW DEC_clear.st1.fb146 DEC_clear.st1.fc146)

def DEC_clear.st1.fR147 : List (Nat × Nat) := [(4841, 4842), (2672787, 2672788), (3122002, 3122003), (3122054, 3122055), (3268900, 3268901), (3268963, 3268973), (3269194, 3269195), (3269289, 3269290), (3269302, 3269303), (3269354, 3269356), (3269357, 3269358)]
kernel_rfl DEC_clear.st1.fh147 : DEC_clear.st1.s148.heap = setAll DEC_clear.st1.s147.heap (rangesOf DEC_clear.st1.s148.heap DEC_clear.st1.fR147 ++ freshOf DEC_clear.st1.s148.heap DEC_clear.st1.s147.next DEC_clear.st1.s148.next)
kernel_rfl DEC_clear.st1.fb147 : footRB DEC_clear.st1.s147 DEC_clear.st1.s148 DEC_clear.st1.fR147 = true
kernel_rfl DEC_clear.st1.fc147 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s147.next && Nat.ble DEC_clear.st1.s148.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR147 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa148 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s148 :=
  DEC_clear.st1.fa147.step (stageFoot_ofRF DEC_clear.st1.fh147 DEC_clear.st1.fb147) (incl_of_footW DEC_clear.st1.fb147 DEC_clear.st1.fc147)

def DEC_clear.st1.fR148 : List (Nat × Nat) := [(3123796, 3123797), (3268861, 3268862), (3268901, 3268903), (3268928, 3268929), (3270321, 3270322), (3270374, 3270375), (3270379, 3270380)]
kernel_rfl DEC_clear.st1.fh148 : DEC_clear.st1.s149.heap = setAll DEC_clear.st1.s148.heap (rangesOf DEC_clear.st1.s149.heap DEC_clear.st1.fR148 ++ freshOf DEC_clear.st1.s149.heap DEC_clear.st1.s148.next DEC_clear.st1.s149.next)
kernel_rfl DEC_clear.st1.fb148 : footRB DEC_clear.st1.s148 DEC_clear.st1.s149 DEC_clear.st1.fR148 = true
kernel_rfl DEC_clear.st1.fc148 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s148.next && Nat.ble DEC_clear.st1.s149.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR148 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa149 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s149 :=
  DEC_clear.st1.fa148.step (stageFoot_ofRF DEC_clear.st1.fh148 DEC_clear.st1.fb148) (incl_of_footW DEC_clear.st1.fb148 DEC_clear.st1.fc148)

def DEC_clear.st1.fR149 : List (Nat × Nat) := []
kernel_rfl DEC_clear.st1.fh149 : DEC_clear.st1.s150.heap = setAll DEC_clear.st1.s149.heap (rangesOf DEC_clear.st1.s150.heap DEC_clear.st1.fR149 ++ freshOf DEC_clear.st1.s150.heap DEC_clear.st1.s149.next DEC_clear.st1.s150.next)
kernel_rfl DEC_clear.st1.fb149 : footRB DEC_clear.st1.s149 DEC_clear.st1.s150 DEC_clear.st1.fR149 = true
kernel_rfl DEC_clear.st1.fc149 : (Nat.ble DEC_clear.st1.s0.next DEC_clear.st1.s149.next && Nat.ble DEC_clear.st1.s150.next DEC_clear.st1.s150.next && coverB DEC_clear.st1.fR149 DEC_clear.st1.wrR DEC_clear.st1.s0.next) = true
theorem DEC_clear.st1.fa150 : FootAcc DEC_clear.st1.wr DEC_clear.st1.s150 DEC_clear.st1.s0 DEC_clear.st1.s150 :=
  DEC_clear.st1.fa149.step (stageFoot_ofRF DEC_clear.st1.fh149 DEC_clear.st1.fb149) (incl_of_footW DEC_clear.st1.fb149 DEC_clear.st1.fc149)

end Host.Load.Run.Tpl

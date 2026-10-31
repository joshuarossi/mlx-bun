import host.sim.template.a4dec_clearGrow.st1.FootS3
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

def DEC_clearGrow.st1.fR128 : List (Nat × Nat) := [(2672708, 2672709), (3100475, 3100476), (3249683, 3249686), (3249731, 3249736), (3249925, 3249926), (3250050, 3250051), (3250136, 3250137), (3250225, 3250226), (3250268, 3250270), (3250591, 3250592), (3250597, 3250598), (3250603, 3250604), (3250623, 3250634), (3250636, 3250638)]
kernel_rfl DEC_clearGrow.st1.fh128 : DEC_clearGrow.st1.s129.heap = setAll DEC_clearGrow.st1.s128.heap (rangesOf DEC_clearGrow.st1.s129.heap DEC_clearGrow.st1.fR128 ++ freshOf DEC_clearGrow.st1.s129.heap DEC_clearGrow.st1.s128.next DEC_clearGrow.st1.s129.next)
kernel_rfl DEC_clearGrow.st1.fb128 : footRB DEC_clearGrow.st1.s128 DEC_clearGrow.st1.s129 DEC_clearGrow.st1.fR128 = true
kernel_rfl DEC_clearGrow.st1.fc128 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s128.next && Nat.ble DEC_clearGrow.st1.s129.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR128 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa129 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s129 :=
  DEC_clearGrow.st1.fa128.step (stageFoot_ofRF DEC_clearGrow.st1.fh128 DEC_clearGrow.st1.fb128) (incl_of_footW DEC_clearGrow.st1.fb128 DEC_clearGrow.st1.fc128)

def DEC_clearGrow.st1.fR129 : List (Nat × Nat) := [(3123796, 3123797), (3249645, 3249646), (3249711, 3249712), (3251225, 3251226), (3251279, 3251280), (3251285, 3251286), (3251291, 3251292), (3251299, 3251300), (3251545, 3251546)]
kernel_rfl DEC_clearGrow.st1.fh129 : DEC_clearGrow.st1.s130.heap = setAll DEC_clearGrow.st1.s129.heap (rangesOf DEC_clearGrow.st1.s130.heap DEC_clearGrow.st1.fR129 ++ freshOf DEC_clearGrow.st1.s130.heap DEC_clearGrow.st1.s129.next DEC_clearGrow.st1.s130.next)
kernel_rfl DEC_clearGrow.st1.fb129 : footRB DEC_clearGrow.st1.s129 DEC_clearGrow.st1.s130 DEC_clearGrow.st1.fR129 = true
kernel_rfl DEC_clearGrow.st1.fc129 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s129.next && Nat.ble DEC_clearGrow.st1.s130.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR129 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa130 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s130 :=
  DEC_clearGrow.st1.fa129.step (stageFoot_ofRF DEC_clearGrow.st1.fh129 DEC_clearGrow.st1.fb129) (incl_of_footW DEC_clearGrow.st1.fb129 DEC_clearGrow.st1.fc129)

def DEC_clearGrow.st1.fR130 : List (Nat × Nat) := [(2672713, 2672714), (3102238, 3102239), (3102667, 3102668), (3251975, 3251978), (3252023, 3252028), (3252117, 3252118), (3252242, 3252243), (3252328, 3252329), (3252417, 3252418), (3252455, 3252462), (3252501, 3252503), (3252555, 3252556), (3252580, 3252581), (3252603, 3252604), (3252614, 3252615)]
kernel_rfl DEC_clearGrow.st1.fh130 : DEC_clearGrow.st1.s131.heap = setAll DEC_clearGrow.st1.s130.heap (rangesOf DEC_clearGrow.st1.s131.heap DEC_clearGrow.st1.fR130 ++ freshOf DEC_clearGrow.st1.s131.heap DEC_clearGrow.st1.s130.next DEC_clearGrow.st1.s131.next)
kernel_rfl DEC_clearGrow.st1.fb130 : footRB DEC_clearGrow.st1.s130 DEC_clearGrow.st1.s131 DEC_clearGrow.st1.fR130 = true
kernel_rfl DEC_clearGrow.st1.fc130 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s130.next && Nat.ble DEC_clearGrow.st1.s131.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR130 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa131 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s131 :=
  DEC_clearGrow.st1.fa130.step (stageFoot_ofRF DEC_clearGrow.st1.fh130 DEC_clearGrow.st1.fb130) (incl_of_footW DEC_clearGrow.st1.fb130 DEC_clearGrow.st1.fc130)

def DEC_clearGrow.st1.fR131 : List (Nat × Nat) := [(3123796, 3123797), (3251937, 3251938), (3252003, 3252004), (3253317, 3253318), (3253371, 3253372), (3253377, 3253378), (3253383, 3253384), (3253391, 3253392), (3253404, 3253406), (3253460, 3253461), (3253488, 3253489), (3253491, 3253501)]
kernel_rfl DEC_clearGrow.st1.fh131 : DEC_clearGrow.st1.s132.heap = setAll DEC_clearGrow.st1.s131.heap (rangesOf DEC_clearGrow.st1.s132.heap DEC_clearGrow.st1.fR131 ++ freshOf DEC_clearGrow.st1.s132.heap DEC_clearGrow.st1.s131.next DEC_clearGrow.st1.s132.next)
kernel_rfl DEC_clearGrow.st1.fb131 : footRB DEC_clearGrow.st1.s131 DEC_clearGrow.st1.s132 DEC_clearGrow.st1.fR131 = true
kernel_rfl DEC_clearGrow.st1.fc131 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s131.next && Nat.ble DEC_clearGrow.st1.s132.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR131 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa132 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s132 :=
  DEC_clearGrow.st1.fa131.step (stageFoot_ofRF DEC_clearGrow.st1.fh131 DEC_clearGrow.st1.fb131) (incl_of_footW DEC_clearGrow.st1.fb131 DEC_clearGrow.st1.fc131)

def DEC_clearGrow.st1.fR132 : List (Nat × Nat) := [(4841, 4842), (2672725, 2672726), (3104626, 3104627), (3104678, 3104679), (3254135, 3254143), (3254366, 3254367), (3254461, 3254462), (3254474, 3254475), (3254547, 3254548)]
kernel_rfl DEC_clearGrow.st1.fh132 : DEC_clearGrow.st1.s133.heap = setAll DEC_clearGrow.st1.s132.heap (rangesOf DEC_clearGrow.st1.s133.heap DEC_clearGrow.st1.fR132 ++ freshOf DEC_clearGrow.st1.s133.heap DEC_clearGrow.st1.s132.next DEC_clearGrow.st1.s133.next)
kernel_rfl DEC_clearGrow.st1.fb132 : footRB DEC_clearGrow.st1.s132 DEC_clearGrow.st1.s133 DEC_clearGrow.st1.fR132 = true
kernel_rfl DEC_clearGrow.st1.fc132 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s132.next && Nat.ble DEC_clearGrow.st1.s133.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR132 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa133 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s133 :=
  DEC_clearGrow.st1.fa132.step (stageFoot_ofRF DEC_clearGrow.st1.fh132 DEC_clearGrow.st1.fb132) (incl_of_footW DEC_clearGrow.st1.fb132 DEC_clearGrow.st1.fc132)

def DEC_clearGrow.st1.fR133 : List (Nat × Nat) := [(3123796, 3123797), (3254033, 3254034), (3254072, 3254075), (3254100, 3254101), (3254143, 3254145), (3255551, 3255552), (3255576, 3255577), (3255592, 3255596)]
kernel_rfl DEC_clearGrow.st1.fh133 : DEC_clearGrow.st1.s134.heap = setAll DEC_clearGrow.st1.s133.heap (rangesOf DEC_clearGrow.st1.s134.heap DEC_clearGrow.st1.fR133 ++ freshOf DEC_clearGrow.st1.s134.heap DEC_clearGrow.st1.s133.next DEC_clearGrow.st1.s134.next)
kernel_rfl DEC_clearGrow.st1.fb133 : footRB DEC_clearGrow.st1.s133 DEC_clearGrow.st1.s134 DEC_clearGrow.st1.fR133 = true
kernel_rfl DEC_clearGrow.st1.fc133 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s133.next && Nat.ble DEC_clearGrow.st1.s134.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR133 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa134 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s134 :=
  DEC_clearGrow.st1.fa133.step (stageFoot_ofRF DEC_clearGrow.st1.fh133 DEC_clearGrow.st1.fb133) (incl_of_footW DEC_clearGrow.st1.fb133 DEC_clearGrow.st1.fc133)

def DEC_clearGrow.st1.fR134 : List (Nat × Nat) := [(2672734, 2672735), (3106536, 3106537), (3256512, 3256517), (3256538, 3256539), (3256556, 3256557), (3256572, 3256574)]
kernel_rfl DEC_clearGrow.st1.fh134 : DEC_clearGrow.st1.s135.heap = setAll DEC_clearGrow.st1.s134.heap (rangesOf DEC_clearGrow.st1.s135.heap DEC_clearGrow.st1.fR134 ++ freshOf DEC_clearGrow.st1.s135.heap DEC_clearGrow.st1.s134.next DEC_clearGrow.st1.s135.next)
kernel_rfl DEC_clearGrow.st1.fb134 : footRB DEC_clearGrow.st1.s134 DEC_clearGrow.st1.s135 DEC_clearGrow.st1.fR134 = true
kernel_rfl DEC_clearGrow.st1.fc134 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s134.next && Nat.ble DEC_clearGrow.st1.s135.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR134 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa135 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s135 :=
  DEC_clearGrow.st1.fa134.step (stageFoot_ofRF DEC_clearGrow.st1.fh134 DEC_clearGrow.st1.fb134) (incl_of_footW DEC_clearGrow.st1.fb134 DEC_clearGrow.st1.fc134)

def DEC_clearGrow.st1.fR135 : List (Nat × Nat) := [(2672734, 2672735), (3106965, 3106966), (3256469, 3256472), (3256517, 3256522), (3256611, 3256612), (3256736, 3256737), (3256822, 3256823), (3256911, 3256912), (3256954, 3256956), (3257277, 3257278), (3257283, 3257284), (3257289, 3257290), (3257318, 3257320), (3257364, 3257365), (3257408, 3257409), (3257430, 3257432), (3257471, 3257472), (3257609, 3257610)]
kernel_rfl DEC_clearGrow.st1.fh135 : DEC_clearGrow.st1.s136.heap = setAll DEC_clearGrow.st1.s135.heap (rangesOf DEC_clearGrow.st1.s136.heap DEC_clearGrow.st1.fR135 ++ freshOf DEC_clearGrow.st1.s136.heap DEC_clearGrow.st1.s135.next DEC_clearGrow.st1.s136.next)
kernel_rfl DEC_clearGrow.st1.fb135 : footRB DEC_clearGrow.st1.s135 DEC_clearGrow.st1.s136 DEC_clearGrow.st1.fR135 = true
kernel_rfl DEC_clearGrow.st1.fc135 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s135.next && Nat.ble DEC_clearGrow.st1.s136.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR135 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa136 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s136 :=
  DEC_clearGrow.st1.fa135.step (stageFoot_ofRF DEC_clearGrow.st1.fh135 DEC_clearGrow.st1.fb135) (incl_of_footW DEC_clearGrow.st1.fb135 DEC_clearGrow.st1.fc135)

def DEC_clearGrow.st1.fR136 : List (Nat × Nat) := [(2672739, 2672740), (3108632, 3108633), (3123796, 3123797), (3256409, 3256410), (3256497, 3256498), (3257811, 3257812), (3257865, 3257866), (3257871, 3257872)]
kernel_rfl DEC_clearGrow.st1.fh136 : DEC_clearGrow.st1.s137.heap = setAll DEC_clearGrow.st1.s136.heap (rangesOf DEC_clearGrow.st1.s137.heap DEC_clearGrow.st1.fR136 ++ freshOf DEC_clearGrow.st1.s137.heap DEC_clearGrow.st1.s136.next DEC_clearGrow.st1.s137.next)
kernel_rfl DEC_clearGrow.st1.fb136 : footRB DEC_clearGrow.st1.s136 DEC_clearGrow.st1.s137 DEC_clearGrow.st1.fR136 = true
kernel_rfl DEC_clearGrow.st1.fc136 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s136.next && Nat.ble DEC_clearGrow.st1.s137.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR136 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa137 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s137 :=
  DEC_clearGrow.st1.fa136.step (stageFoot_ofRF DEC_clearGrow.st1.fh136 DEC_clearGrow.st1.fb136) (incl_of_footW DEC_clearGrow.st1.fb136 DEC_clearGrow.st1.fc136)

def DEC_clearGrow.st1.fR137 : List (Nat × Nat) := [(2672739, 2672740), (3109061, 3109062), (3258565, 3258568), (3258613, 3258618), (3258707, 3258708), (3258832, 3258833), (3258918, 3258919), (3259007, 3259008), (3259050, 3259052), (3259373, 3259374), (3259379, 3259380), (3259385, 3259386), (3259414, 3259416), (3259460, 3259461), (3259504, 3259505), (3259526, 3259528), (3259567, 3259568), (3259599, 3259600), (3259602, 3259612)]
kernel_rfl DEC_clearGrow.st1.fh137 : DEC_clearGrow.st1.s138.heap = setAll DEC_clearGrow.st1.s137.heap (rangesOf DEC_clearGrow.st1.s138.heap DEC_clearGrow.st1.fR137 ++ freshOf DEC_clearGrow.st1.s138.heap DEC_clearGrow.st1.s137.next DEC_clearGrow.st1.s138.next)
kernel_rfl DEC_clearGrow.st1.fb137 : footRB DEC_clearGrow.st1.s137 DEC_clearGrow.st1.s138 DEC_clearGrow.st1.fR137 = true
kernel_rfl DEC_clearGrow.st1.fc137 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s137.next && Nat.ble DEC_clearGrow.st1.s138.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR137 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa138 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s138 :=
  DEC_clearGrow.st1.fa137.step (stageFoot_ofRF DEC_clearGrow.st1.fh137 DEC_clearGrow.st1.fb137) (incl_of_footW DEC_clearGrow.st1.fb137 DEC_clearGrow.st1.fc137)

def DEC_clearGrow.st1.fR138 : List (Nat × Nat) := [(2672744, 2672745), (3110828, 3110829), (3123796, 3123797), (3258527, 3258528), (3258593, 3258594), (3259907, 3259908), (3259961, 3259962), (3259967, 3259968), (3259973, 3259974), (3260227, 3260228), (3260248, 3260249), (3260298, 3260299), (3260321, 3260322), (3260464, 3260465), (3260500, 3260506), (3260540, 3260541)]
kernel_rfl DEC_clearGrow.st1.fh138 : DEC_clearGrow.st1.s139.heap = setAll DEC_clearGrow.st1.s138.heap (rangesOf DEC_clearGrow.st1.s139.heap DEC_clearGrow.st1.fR138 ++ freshOf DEC_clearGrow.st1.s139.heap DEC_clearGrow.st1.s138.next DEC_clearGrow.st1.s139.next)
kernel_rfl DEC_clearGrow.st1.fb138 : footRB DEC_clearGrow.st1.s138 DEC_clearGrow.st1.s139 DEC_clearGrow.st1.fR138 = true
kernel_rfl DEC_clearGrow.st1.fc138 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s138.next && Nat.ble DEC_clearGrow.st1.s139.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR138 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa139 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s139 :=
  DEC_clearGrow.st1.fa138.step (stageFoot_ofRF DEC_clearGrow.st1.fh138 DEC_clearGrow.st1.fb138) (incl_of_footW DEC_clearGrow.st1.fb138 DEC_clearGrow.st1.fc138)

def DEC_clearGrow.st1.fR139 : List (Nat × Nat) := [(2672744, 2672745), (3111257, 3111258), (3260661, 3260664), (3260709, 3260714), (3260803, 3260804), (3261028, 3261029), (3261114, 3261115), (3261203, 3261204), (3261246, 3261248), (3261512, 3261513), (3261569, 3261570), (3261575, 3261576), (3261581, 3261582)]
kernel_rfl DEC_clearGrow.st1.fh139 : DEC_clearGrow.st1.s140.heap = setAll DEC_clearGrow.st1.s139.heap (rangesOf DEC_clearGrow.st1.s140.heap DEC_clearGrow.st1.fR139 ++ freshOf DEC_clearGrow.st1.s140.heap DEC_clearGrow.st1.s139.next DEC_clearGrow.st1.s140.next)
kernel_rfl DEC_clearGrow.st1.fb139 : footRB DEC_clearGrow.st1.s139 DEC_clearGrow.st1.s140 DEC_clearGrow.st1.fR139 = true
kernel_rfl DEC_clearGrow.st1.fc139 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s139.next && Nat.ble DEC_clearGrow.st1.s140.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR139 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa140 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s140 :=
  DEC_clearGrow.st1.fa139.step (stageFoot_ofRF DEC_clearGrow.st1.fh139 DEC_clearGrow.st1.fb139) (incl_of_footW DEC_clearGrow.st1.fb139 DEC_clearGrow.st1.fc139)

def DEC_clearGrow.st1.fR140 : List (Nat × Nat) := [(3123796, 3123797), (3260623, 3260624), (3260689, 3260690), (3262203, 3262204), (3262257, 3262258), (3262263, 3262264), (3262269, 3262270), (3262277, 3262278), (3262291, 3262292), (3262492, 3262493), (3262516, 3262517)]
kernel_rfl DEC_clearGrow.st1.fh140 : DEC_clearGrow.st1.s141.heap = setAll DEC_clearGrow.st1.s140.heap (rangesOf DEC_clearGrow.st1.s141.heap DEC_clearGrow.st1.fR140 ++ freshOf DEC_clearGrow.st1.s141.heap DEC_clearGrow.st1.s140.next DEC_clearGrow.st1.s141.next)
kernel_rfl DEC_clearGrow.st1.fb140 : footRB DEC_clearGrow.st1.s140 DEC_clearGrow.st1.s141 DEC_clearGrow.st1.fR140 = true
kernel_rfl DEC_clearGrow.st1.fc140 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s140.next && Nat.ble DEC_clearGrow.st1.s141.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR140 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa141 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s141 :=
  DEC_clearGrow.st1.fa140.step (stageFoot_ofRF DEC_clearGrow.st1.fh140 DEC_clearGrow.st1.fb140) (incl_of_footW DEC_clearGrow.st1.fb140 DEC_clearGrow.st1.fc140)

def DEC_clearGrow.st1.fR141 : List (Nat × Nat) := [(4841, 4842), (2672756, 2672757), (3113316, 3113317), (3113368, 3113369), (3263021, 3263030), (3263252, 3263253), (3263347, 3263348), (3263433, 3263434), (3263522, 3263523), (3263532, 3263533)]
kernel_rfl DEC_clearGrow.st1.fh141 : DEC_clearGrow.st1.s142.heap = setAll DEC_clearGrow.st1.s141.heap (rangesOf DEC_clearGrow.st1.s142.heap DEC_clearGrow.st1.fR141 ++ freshOf DEC_clearGrow.st1.s142.heap DEC_clearGrow.st1.s141.next DEC_clearGrow.st1.s142.next)
kernel_rfl DEC_clearGrow.st1.fb141 : footRB DEC_clearGrow.st1.s141 DEC_clearGrow.st1.s142 DEC_clearGrow.st1.fR141 = true
kernel_rfl DEC_clearGrow.st1.fc141 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s141.next && Nat.ble DEC_clearGrow.st1.s142.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR141 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa142 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s142 :=
  DEC_clearGrow.st1.fa141.step (stageFoot_ofRF DEC_clearGrow.st1.fh141 DEC_clearGrow.st1.fb141) (incl_of_footW DEC_clearGrow.st1.fb141 DEC_clearGrow.st1.fc141)

def DEC_clearGrow.st1.fR142 : List (Nat × Nat) := [(3123796, 3123797), (3262919, 3262920), (3262958, 3262961), (3262986, 3262987), (3263030, 3263031), (3264490, 3264491), (3264502, 3264503), (3264554, 3264556), (3264557, 3264558), (3264574, 3264575)]
kernel_rfl DEC_clearGrow.st1.fh142 : DEC_clearGrow.st1.s143.heap = setAll DEC_clearGrow.st1.s142.heap (rangesOf DEC_clearGrow.st1.s143.heap DEC_clearGrow.st1.fR142 ++ freshOf DEC_clearGrow.st1.s143.heap DEC_clearGrow.st1.s142.next DEC_clearGrow.st1.s143.next)
kernel_rfl DEC_clearGrow.st1.fb142 : footRB DEC_clearGrow.st1.s142 DEC_clearGrow.st1.s143 DEC_clearGrow.st1.fR142 = true
kernel_rfl DEC_clearGrow.st1.fc142 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s142.next && Nat.ble DEC_clearGrow.st1.s143.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR142 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa143 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s143 :=
  DEC_clearGrow.st1.fa142.step (stageFoot_ofRF DEC_clearGrow.st1.fh142 DEC_clearGrow.st1.fb142) (incl_of_footW DEC_clearGrow.st1.fb142 DEC_clearGrow.st1.fc142)

def DEC_clearGrow.st1.fR143 : List (Nat × Nat) := [(2672765, 2672766), (3115226, 3115227), (3115655, 3115656), (3265399, 3265405), (3265497, 3265498), (3265513, 3265514), (3265531, 3265532)]
kernel_rfl DEC_clearGrow.st1.fh143 : DEC_clearGrow.st1.s144.heap = setAll DEC_clearGrow.st1.s143.heap (rangesOf DEC_clearGrow.st1.s144.heap DEC_clearGrow.st1.fR143 ++ freshOf DEC_clearGrow.st1.s144.heap DEC_clearGrow.st1.s143.next DEC_clearGrow.st1.s144.next)
kernel_rfl DEC_clearGrow.st1.fb143 : footRB DEC_clearGrow.st1.s143 DEC_clearGrow.st1.s144 DEC_clearGrow.st1.fR143 = true
kernel_rfl DEC_clearGrow.st1.fc143 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s143.next && Nat.ble DEC_clearGrow.st1.s144.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR143 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa144 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s144 :=
  DEC_clearGrow.st1.fa143.step (stageFoot_ofRF DEC_clearGrow.st1.fh143 DEC_clearGrow.st1.fb143) (incl_of_footW DEC_clearGrow.st1.fb143 DEC_clearGrow.st1.fc143)

def DEC_clearGrow.st1.fR144 : List (Nat × Nat) := [(3265355, 3265358), (3265405, 3265408), (3265622, 3265623), (3266495, 3266496), (3266552, 3266560)]
kernel_rfl DEC_clearGrow.st1.fh144 : DEC_clearGrow.st1.s145.heap = setAll DEC_clearGrow.st1.s144.heap (rangesOf DEC_clearGrow.st1.s145.heap DEC_clearGrow.st1.fR144 ++ freshOf DEC_clearGrow.st1.s145.heap DEC_clearGrow.st1.s144.next DEC_clearGrow.st1.s145.next)
kernel_rfl DEC_clearGrow.st1.fb144 : footRB DEC_clearGrow.st1.s144 DEC_clearGrow.st1.s145 DEC_clearGrow.st1.fR144 = true
kernel_rfl DEC_clearGrow.st1.fc144 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s144.next && Nat.ble DEC_clearGrow.st1.s145.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR144 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa145 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s145 :=
  DEC_clearGrow.st1.fa144.step (stageFoot_ofRF DEC_clearGrow.st1.fh144 DEC_clearGrow.st1.fb144) (incl_of_footW DEC_clearGrow.st1.fb144 DEC_clearGrow.st1.fc144)

def DEC_clearGrow.st1.fR145 : List (Nat × Nat) := [(2672770, 2672771), (3117422, 3117423), (3123796, 3123797), (3265295, 3265296), (3265383, 3265384), (3266797, 3266798), (3266851, 3266852), (3266857, 3266858), (3267468, 3267469), (3267503, 3267505), (3267506, 3267507)]
kernel_rfl DEC_clearGrow.st1.fh145 : DEC_clearGrow.st1.s146.heap = setAll DEC_clearGrow.st1.s145.heap (rangesOf DEC_clearGrow.st1.s146.heap DEC_clearGrow.st1.fR145 ++ freshOf DEC_clearGrow.st1.s146.heap DEC_clearGrow.st1.s145.next DEC_clearGrow.st1.s146.next)
kernel_rfl DEC_clearGrow.st1.fb145 : footRB DEC_clearGrow.st1.s145 DEC_clearGrow.st1.s146 DEC_clearGrow.st1.fR145 = true
kernel_rfl DEC_clearGrow.st1.fc145 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s145.next && Nat.ble DEC_clearGrow.st1.s146.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR145 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa146 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s146 :=
  DEC_clearGrow.st1.fa145.step (stageFoot_ofRF DEC_clearGrow.st1.fh145 DEC_clearGrow.st1.fb145) (incl_of_footW DEC_clearGrow.st1.fb145 DEC_clearGrow.st1.fc145)

def DEC_clearGrow.st1.fR146 : List (Nat × Nat) := [(2672770, 2672771), (3117851, 3117852), (3267551, 3267554), (3267599, 3267604), (3267693, 3267694), (3267818, 3267819), (3267904, 3267905), (3267993, 3267994), (3268036, 3268038), (3268359, 3268360), (3268365, 3268366), (3268371, 3268372), (3268400, 3268402), (3268446, 3268447), (3268490, 3268491), (3268512, 3268514), (3268553, 3268554), (3268585, 3268586), (3268588, 3268598)]
kernel_rfl DEC_clearGrow.st1.fh146 : DEC_clearGrow.st1.s147.heap = setAll DEC_clearGrow.st1.s146.heap (rangesOf DEC_clearGrow.st1.s147.heap DEC_clearGrow.st1.fR146 ++ freshOf DEC_clearGrow.st1.s147.heap DEC_clearGrow.st1.s146.next DEC_clearGrow.st1.s147.next)
kernel_rfl DEC_clearGrow.st1.fb146 : footRB DEC_clearGrow.st1.s146 DEC_clearGrow.st1.s147 DEC_clearGrow.st1.fR146 = true
kernel_rfl DEC_clearGrow.st1.fc146 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s146.next && Nat.ble DEC_clearGrow.st1.s147.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR146 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa147 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s147 :=
  DEC_clearGrow.st1.fa146.step (stageFoot_ofRF DEC_clearGrow.st1.fh146 DEC_clearGrow.st1.fb146) (incl_of_footW DEC_clearGrow.st1.fb146 DEC_clearGrow.st1.fc146)

def DEC_clearGrow.st1.fR147 : List (Nat × Nat) := [(2672775, 2672776), (3119518, 3119519), (3123796, 3123797), (3267513, 3267514), (3267579, 3267580), (3268893, 3268894), (3268947, 3268948), (3268953, 3268954), (3268959, 3268960), (3269213, 3269214), (3269234, 3269235), (3269284, 3269285), (3269307, 3269308), (3269450, 3269451), (3269479, 3269480), (3269482, 3269492), (3269514, 3269516)]
kernel_rfl DEC_clearGrow.st1.fh147 : DEC_clearGrow.st1.s148.heap = setAll DEC_clearGrow.st1.s147.heap (rangesOf DEC_clearGrow.st1.s148.heap DEC_clearGrow.st1.fR147 ++ freshOf DEC_clearGrow.st1.s148.heap DEC_clearGrow.st1.s147.next DEC_clearGrow.st1.s148.next)
kernel_rfl DEC_clearGrow.st1.fb147 : footRB DEC_clearGrow.st1.s147 DEC_clearGrow.st1.s148 DEC_clearGrow.st1.fR147 = true
kernel_rfl DEC_clearGrow.st1.fc147 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s147.next && Nat.ble DEC_clearGrow.st1.s148.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR147 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa148 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s148 :=
  DEC_clearGrow.st1.fa147.step (stageFoot_ofRF DEC_clearGrow.st1.fh147 DEC_clearGrow.st1.fb147) (incl_of_footW DEC_clearGrow.st1.fb147 DEC_clearGrow.st1.fc147)

def DEC_clearGrow.st1.fR148 : List (Nat × Nat) := [(2672775, 2672776), (3119947, 3119948), (3269647, 3269650), (3269695, 3269700), (3269789, 3269790), (3269914, 3269915), (3270000, 3270001), (3270089, 3270090), (3270132, 3270134), (3270455, 3270456), (3270461, 3270462), (3270467, 3270468), (3270493, 3270498), (3270542, 3270543), (3270581, 3270583)]
kernel_rfl DEC_clearGrow.st1.fh148 : DEC_clearGrow.st1.s149.heap = setAll DEC_clearGrow.st1.s148.heap (rangesOf DEC_clearGrow.st1.s149.heap DEC_clearGrow.st1.fR148 ++ freshOf DEC_clearGrow.st1.s149.heap DEC_clearGrow.st1.s148.next DEC_clearGrow.st1.s149.next)
kernel_rfl DEC_clearGrow.st1.fb148 : footRB DEC_clearGrow.st1.s148 DEC_clearGrow.st1.s149 DEC_clearGrow.st1.fR148 = true
kernel_rfl DEC_clearGrow.st1.fc148 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s148.next && Nat.ble DEC_clearGrow.st1.s149.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR148 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa149 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s149 :=
  DEC_clearGrow.st1.fa148.step (stageFoot_ofRF DEC_clearGrow.st1.fh148 DEC_clearGrow.st1.fb148) (incl_of_footW DEC_clearGrow.st1.fb148 DEC_clearGrow.st1.fc148)

def DEC_clearGrow.st1.fR149 : List (Nat × Nat) := [(3123796, 3123797), (3269609, 3269610), (3269675, 3269676), (3271089, 3271090), (3271143, 3271144), (3271149, 3271150), (3271155, 3271156), (3271409, 3271410), (3271430, 3271431), (3271480, 3271481), (3271498, 3271500), (3271503, 3271504)]
kernel_rfl DEC_clearGrow.st1.fh149 : DEC_clearGrow.st1.s150.heap = setAll DEC_clearGrow.st1.s149.heap (rangesOf DEC_clearGrow.st1.s150.heap DEC_clearGrow.st1.fR149 ++ freshOf DEC_clearGrow.st1.s150.heap DEC_clearGrow.st1.s149.next DEC_clearGrow.st1.s150.next)
kernel_rfl DEC_clearGrow.st1.fb149 : footRB DEC_clearGrow.st1.s149 DEC_clearGrow.st1.s150 DEC_clearGrow.st1.fR149 = true
kernel_rfl DEC_clearGrow.st1.fc149 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s149.next && Nat.ble DEC_clearGrow.st1.s150.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR149 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa150 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s150 :=
  DEC_clearGrow.st1.fa149.step (stageFoot_ofRF DEC_clearGrow.st1.fh149 DEC_clearGrow.st1.fb149) (incl_of_footW DEC_clearGrow.st1.fb149 DEC_clearGrow.st1.fc149)

def DEC_clearGrow.st1.fR150 : List (Nat × Nat) := [(4841, 4842), (2672787, 2672788), (3122002, 3122003), (3122054, 3122055), (3271840, 3271843), (3271903, 3271913), (3272229, 3272230), (3272404, 3272405), (3272472, 3272473), (3272505, 3272506)]
kernel_rfl DEC_clearGrow.st1.fh150 : DEC_clearGrow.st1.s151.heap = setAll DEC_clearGrow.st1.s150.heap (rangesOf DEC_clearGrow.st1.s151.heap DEC_clearGrow.st1.fR150 ++ freshOf DEC_clearGrow.st1.s151.heap DEC_clearGrow.st1.s150.next DEC_clearGrow.st1.s151.next)
kernel_rfl DEC_clearGrow.st1.fb150 : footRB DEC_clearGrow.st1.s150 DEC_clearGrow.st1.s151 DEC_clearGrow.st1.fR150 = true
kernel_rfl DEC_clearGrow.st1.fc150 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s150.next && Nat.ble DEC_clearGrow.st1.s151.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR150 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa151 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s151 :=
  DEC_clearGrow.st1.fa150.step (stageFoot_ofRF DEC_clearGrow.st1.fh150 DEC_clearGrow.st1.fb150) (incl_of_footW DEC_clearGrow.st1.fb150 DEC_clearGrow.st1.fc150)

def DEC_clearGrow.st1.fR151 : List (Nat × Nat) := [(3123796, 3123797), (3271801, 3271802), (3271868, 3271869), (3273457, 3273458), (3273515, 3273516), (3273521, 3273522), (3273527, 3273528), (3273535, 3273536), (3273542, 3273544)]
kernel_rfl DEC_clearGrow.st1.fh151 : DEC_clearGrow.st1.s152.heap = setAll DEC_clearGrow.st1.s151.heap (rangesOf DEC_clearGrow.st1.s152.heap DEC_clearGrow.st1.fR151 ++ freshOf DEC_clearGrow.st1.s152.heap DEC_clearGrow.st1.s151.next DEC_clearGrow.st1.s152.next)
kernel_rfl DEC_clearGrow.st1.fb151 : footRB DEC_clearGrow.st1.s151 DEC_clearGrow.st1.s152 DEC_clearGrow.st1.fR151 = true
kernel_rfl DEC_clearGrow.st1.fc151 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s151.next && Nat.ble DEC_clearGrow.st1.s152.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR151 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa152 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s152 :=
  DEC_clearGrow.st1.fa151.step (stageFoot_ofRF DEC_clearGrow.st1.fh151 DEC_clearGrow.st1.fb151) (incl_of_footW DEC_clearGrow.st1.fb151 DEC_clearGrow.st1.fc151)

def DEC_clearGrow.st1.fR152 : List (Nat × Nat) := []
kernel_rfl DEC_clearGrow.st1.fh152 : DEC_clearGrow.st1.s153.heap = setAll DEC_clearGrow.st1.s152.heap (rangesOf DEC_clearGrow.st1.s153.heap DEC_clearGrow.st1.fR152 ++ freshOf DEC_clearGrow.st1.s153.heap DEC_clearGrow.st1.s152.next DEC_clearGrow.st1.s153.next)
kernel_rfl DEC_clearGrow.st1.fb152 : footRB DEC_clearGrow.st1.s152 DEC_clearGrow.st1.s153 DEC_clearGrow.st1.fR152 = true
kernel_rfl DEC_clearGrow.st1.fc152 : (Nat.ble DEC_clearGrow.st1.s0.next DEC_clearGrow.st1.s152.next && Nat.ble DEC_clearGrow.st1.s153.next DEC_clearGrow.st1.s153.next && coverB DEC_clearGrow.st1.fR152 DEC_clearGrow.st1.wrR DEC_clearGrow.st1.s0.next) = true
theorem DEC_clearGrow.st1.fa153 : FootAcc DEC_clearGrow.st1.wr DEC_clearGrow.st1.s153 DEC_clearGrow.st1.s0 DEC_clearGrow.st1.s153 :=
  DEC_clearGrow.st1.fa152.step (stageFoot_ofRF DEC_clearGrow.st1.fh152 DEC_clearGrow.st1.fb152) (incl_of_footW DEC_clearGrow.st1.fb152 DEC_clearGrow.st1.fc152)

end Host.Load.Run.Tpl

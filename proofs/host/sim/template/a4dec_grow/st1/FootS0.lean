import host.sim.template.a4dec_grow.st1.H4
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `DEC_grow.st1`'s site template per stream state (`stageFoot_ofRF`, composed by `FootAcc`): each state's written ranges and fresh range,
its written addresses on the return state's written list `DEC_grow.st1.wr`. -/

/-- The written heap ranges below the start's counter. -/
def DEC_grow.st1.wrR : List (Nat × Nat) := [(4841, 4842), (2672300, 2672301), (2672305, 2672306), (2672310, 2672311), (2672322, 2672323), (2672331, 2672332), (2672336, 2672337), (2672341, 2672342), (2672353, 2672354), (2672362, 2672363), (2672367, 2672368), (2672372, 2672373), (2672384, 2672385), (2672393, 2672394), (2672398, 2672399), (2672403, 2672404), (2672415, 2672416), (2672424, 2672425), (2672429, 2672430), (2672434, 2672435), (2672446, 2672447), (2672455, 2672456), (2672460, 2672461), (2672465, 2672466), (2672477, 2672478), (2672486, 2672487), (2672491, 2672492), (2672496, 2672497), (2672508, 2672509), (2672517, 2672518), (2672522, 2672523), (2672527, 2672528), (2672539, 2672540), (2672548, 2672549), (2672553, 2672554), (2672558, 2672559), (2672570, 2672571), (2672579, 2672580), (2672584, 2672585), (2672589, 2672590), (2672601, 2672602), (2672610, 2672611), (2672615, 2672616), (2672620, 2672621), (2672632, 2672633), (2672641, 2672642), (2672646, 2672647), (2672651, 2672652), (2672663, 2672664), (2672672, 2672673), (2672677, 2672678), (2672682, 2672683), (2672694, 2672695), (2672703, 2672704), (2672708, 2672709), (2672713, 2672714), (2672725, 2672726), (2672734, 2672735), (2672739, 2672740), (2672744, 2672745), (2672756, 2672757), (2672765, 2672766), (2672770, 2672771), (2672775, 2672776), (2672787, 2672788), (2976628, 2976629), (2977057, 2977058), (2978924, 2978925), (2979353, 2979354), (2981216, 2981217), (2981645, 2981646), (2983600, 2983601), (2983652, 2983653), (2985606, 2985607), (2986035, 2986036), (2987798, 2987799), (2988227, 2988228), (2990090, 2990091), (2990519, 2990520), (2992574, 2992575), (2992626, 2992627), (2994680, 2994681), (2995109, 2995110), (2997072, 2997073), (2997501, 2997502), (2999464, 2999465), (2999893, 2999894), (3001948, 3001949), (3002000, 3002001), (3004058, 3004059), (3004487, 3004488), (3006450, 3006451), (3006879, 3006880), (3008846, 3008847), (3009275, 3009276), (3011330, 3011331), (3011382, 3011383), (3013440, 3013441), (3013869, 3013870), (3015836, 3015837), (3016265, 3016266), (3018232, 3018233), (3018661, 3018662), (3020720, 3020721), (3020772, 3020773), (3022826, 3022827), (3023255, 3023256), (3025218, 3025219), (3025647, 3025648), (3027610, 3027611), (3028039, 3028040), (3030094, 3030095), (3030146, 3030147), (3032200, 3032201), (3032629, 3032630), (3034492, 3034493), (3034921, 3034922), (3036884, 3036885), (3037313, 3037314), (3039368, 3039369), (3039420, 3039421), (3041474, 3041475), (3041903, 3041904), (3043866, 3043867), (3044295, 3044296), (3046262, 3046263), (3046691, 3046692), (3048746, 3048747), (3048798, 3048799), (3050856, 3050857), (3051285, 3051286), (3053252, 3053253), (3053681, 3053682), (3055648, 3055649), (3056077, 3056078), (3058132, 3058133), (3058184, 3058185), (3060238, 3060239), (3060667, 3060668), (3062630, 3062631), (3063059, 3063060), (3065022, 3065023), (3065451, 3065452), (3067506, 3067507), (3067558, 3067559), (3069612, 3069613), (3070041, 3070042), (3072004, 3072005), (3072433, 3072434), (3074396, 3074397), (3074825, 3074826), (3076880, 3076881), (3076932, 3076933), (3078986, 3078987), (3079415, 3079416), (3081378, 3081379), (3081807, 3081808), (3083774, 3083775), (3084203, 3084204), (3086262, 3086263), (3086314, 3086315), (3088372, 3088373), (3088801, 3088802), (3090768, 3090769), (3091197, 3091198), (3093164, 3093165), (3093593, 3093594), (3095648, 3095649), (3095700, 3095701), (3097754, 3097755), (3098183, 3098184), (3100046, 3100047), (3100475, 3100476), (3102238, 3102239), (3102667, 3102668), (3104626, 3104627), (3104678, 3104679), (3106536, 3106537), (3106965, 3106966), (3108632, 3108633), (3109061, 3109062), (3110828, 3110829), (3111257, 3111258), (3113316, 3113317), (3113368, 3113369), (3115226, 3115227), (3115655, 3115656), (3117422, 3117423), (3117851, 3117852), (3119518, 3119519), (3119947, 3119948), (3122002, 3122003), (3122054, 3122055)]
/-- The written and fresh addresses of the return state. -/
noncomputable def DEC_grow.st1.wr : List Nat := footW DEC_grow.st1.s153 DEC_grow.st1.wrR DEC_grow.st1.s0.next

theorem DEC_grow.st1.fa0 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s0 := FootAcc.start _ _ _

def DEC_grow.st1.fR0 : List (Nat × Nat) := [(2672300, 2672301), (2976628, 2976629)]
kernel_rfl DEC_grow.st1.fh0 : DEC_grow.st1.s1.heap = setAll DEC_grow.st1.s0.heap (rangesOf DEC_grow.st1.s1.heap DEC_grow.st1.fR0 ++ freshOf DEC_grow.st1.s1.heap DEC_grow.st1.s0.next DEC_grow.st1.s1.next)
kernel_rfl DEC_grow.st1.fb0 : footRB DEC_grow.st1.s0 DEC_grow.st1.s1 DEC_grow.st1.fR0 = true
kernel_rfl DEC_grow.st1.fc0 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s0.next && Nat.ble DEC_grow.st1.s1.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR0 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa1 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s1 :=
  DEC_grow.st1.fa0.step (stageFoot_ofRF DEC_grow.st1.fh0 DEC_grow.st1.fb0) (incl_of_footW DEC_grow.st1.fb0 DEC_grow.st1.fc0)

def DEC_grow.st1.fR1 : List (Nat × Nat) := [(2672300, 2672301), (2977057, 2977058), (3123816, 3123819), (3123864, 3123869), (3123958, 3123959), (3124083, 3124084), (3124169, 3124170), (3124258, 3124259), (3124301, 3124303), (3124624, 3124625), (3124630, 3124631), (3124636, 3124637), (3124664, 3124667), (3124711, 3124712), (3124755, 3124756)]
kernel_rfl DEC_grow.st1.fh1 : DEC_grow.st1.s2.heap = setAll DEC_grow.st1.s1.heap (rangesOf DEC_grow.st1.s2.heap DEC_grow.st1.fR1 ++ freshOf DEC_grow.st1.s2.heap DEC_grow.st1.s1.next DEC_grow.st1.s2.next)
kernel_rfl DEC_grow.st1.fb1 : footRB DEC_grow.st1.s1 DEC_grow.st1.s2 DEC_grow.st1.fR1 = true
kernel_rfl DEC_grow.st1.fc1 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s1.next && Nat.ble DEC_grow.st1.s2.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR1 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa2 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s2 :=
  DEC_grow.st1.fa1.step (stageFoot_ofRF DEC_grow.st1.fh1 DEC_grow.st1.fb1) (incl_of_footW DEC_grow.st1.fb1 DEC_grow.st1.fc1)

def DEC_grow.st1.fR2 : List (Nat × Nat) := [(3123774, 3123775), (3123795, 3123796), (3123844, 3123845), (3125158, 3125159), (3125212, 3125213), (3125218, 3125219), (3125224, 3125225), (3125478, 3125479), (3125499, 3125500), (3125549, 3125550), (3125571, 3125573), (3125605, 3125606), (3125608, 3125618), (3125690, 3125691)]
kernel_rfl DEC_grow.st1.fh2 : DEC_grow.st1.s3.heap = setAll DEC_grow.st1.s2.heap (rangesOf DEC_grow.st1.s3.heap DEC_grow.st1.fR2 ++ freshOf DEC_grow.st1.s3.heap DEC_grow.st1.s2.next DEC_grow.st1.s3.next)
kernel_rfl DEC_grow.st1.fb2 : footRB DEC_grow.st1.s2 DEC_grow.st1.s3 DEC_grow.st1.fR2 = true
kernel_rfl DEC_grow.st1.fc2 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s2.next && Nat.ble DEC_grow.st1.s3.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR2 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa3 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s3 :=
  DEC_grow.st1.fa2.step (stageFoot_ofRF DEC_grow.st1.fh2 DEC_grow.st1.fb2) (incl_of_footW DEC_grow.st1.fb2 DEC_grow.st1.fc2)

def DEC_grow.st1.fR3 : List (Nat × Nat) := [(2672305, 2672306), (2978924, 2978925), (2979353, 2979354), (3125912, 3125915), (3125960, 3125965), (3126154, 3126155), (3126379, 3126380), (3126465, 3126466), (3126554, 3126555), (3126592, 3126599), (3126638, 3126640), (3126692, 3126693), (3126715, 3126718), (3126721, 3126722)]
kernel_rfl DEC_grow.st1.fh3 : DEC_grow.st1.s4.heap = setAll DEC_grow.st1.s3.heap (rangesOf DEC_grow.st1.s4.heap DEC_grow.st1.fR3 ++ freshOf DEC_grow.st1.s4.heap DEC_grow.st1.s3.next DEC_grow.st1.s4.next)
kernel_rfl DEC_grow.st1.fb3 : footRB DEC_grow.st1.s3 DEC_grow.st1.s4 DEC_grow.st1.fR3 = true
kernel_rfl DEC_grow.st1.fc3 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s3.next && Nat.ble DEC_grow.st1.s4.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR3 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa4 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s4 :=
  DEC_grow.st1.fa3.step (stageFoot_ofRF DEC_grow.st1.fh3 DEC_grow.st1.fb3) (incl_of_footW DEC_grow.st1.fb3 DEC_grow.st1.fc3)

def DEC_grow.st1.fR4 : List (Nat × Nat) := [(3123795, 3123796), (3125874, 3125875), (3125940, 3125941), (3127454, 3127455), (3127508, 3127509), (3127514, 3127515), (3127520, 3127521), (3127528, 3127529), (3127541, 3127543), (3127597, 3127598), (3127625, 3127626), (3127628, 3127638)]
kernel_rfl DEC_grow.st1.fh4 : DEC_grow.st1.s5.heap = setAll DEC_grow.st1.s4.heap (rangesOf DEC_grow.st1.s5.heap DEC_grow.st1.fR4 ++ freshOf DEC_grow.st1.s5.heap DEC_grow.st1.s4.next DEC_grow.st1.s5.next)
kernel_rfl DEC_grow.st1.fb4 : footRB DEC_grow.st1.s4 DEC_grow.st1.s5 DEC_grow.st1.fR4 = true
kernel_rfl DEC_grow.st1.fc4 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s4.next && Nat.ble DEC_grow.st1.s5.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR4 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa5 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s5 :=
  DEC_grow.st1.fa4.step (stageFoot_ofRF DEC_grow.st1.fh4 DEC_grow.st1.fb4) (incl_of_footW DEC_grow.st1.fb4 DEC_grow.st1.fc4)

def DEC_grow.st1.fR5 : List (Nat × Nat) := [(2672310, 2672311), (2981216, 2981217), (2981645, 2981646), (3128248, 3128255), (3128446, 3128447), (3128635, 3128636)]
kernel_rfl DEC_grow.st1.fh5 : DEC_grow.st1.s6.heap = setAll DEC_grow.st1.s5.heap (rangesOf DEC_grow.st1.s6.heap DEC_grow.st1.fR5 ++ freshOf DEC_grow.st1.s6.heap DEC_grow.st1.s5.next DEC_grow.st1.s6.next)
kernel_rfl DEC_grow.st1.fb5 : footRB DEC_grow.st1.s5 DEC_grow.st1.s6 DEC_grow.st1.fR5 = true
kernel_rfl DEC_grow.st1.fc5 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s5.next && Nat.ble DEC_grow.st1.s6.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR5 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa6 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s6 :=
  DEC_grow.st1.fa5.step (stageFoot_ofRF DEC_grow.st1.fh5 DEC_grow.st1.fb5) (incl_of_footW DEC_grow.st1.fb5 DEC_grow.st1.fc5)

def DEC_grow.st1.fR6 : List (Nat × Nat) := [(3123795, 3123796), (3128166, 3128167), (3128204, 3128207), (3128232, 3128233), (3128255, 3128257), (3129630, 3129631), (3129655, 3129657), (3129658, 3129659)]
kernel_rfl DEC_grow.st1.fh6 : DEC_grow.st1.s7.heap = setAll DEC_grow.st1.s6.heap (rangesOf DEC_grow.st1.s7.heap DEC_grow.st1.fR6 ++ freshOf DEC_grow.st1.s7.heap DEC_grow.st1.s6.next DEC_grow.st1.s7.next)
kernel_rfl DEC_grow.st1.fb6 : footRB DEC_grow.st1.s6 DEC_grow.st1.s7 DEC_grow.st1.fR6 = true
kernel_rfl DEC_grow.st1.fc6 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s6.next && Nat.ble DEC_grow.st1.s7.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR6 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa7 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s7 :=
  DEC_grow.st1.fa6.step (stageFoot_ofRF DEC_grow.st1.fh6 DEC_grow.st1.fb6) (incl_of_footW DEC_grow.st1.fb6 DEC_grow.st1.fc6)

def DEC_grow.st1.fR7 : List (Nat × Nat) := [(4841, 4842), (2672322, 2672323), (2983600, 2983601), (2983652, 2983653), (3130555, 3130563), (3130587, 3130588), (3130639, 3130641), (3130642, 3130643)]
kernel_rfl DEC_grow.st1.fh7 : DEC_grow.st1.s8.heap = setAll DEC_grow.st1.s7.heap (rangesOf DEC_grow.st1.s8.heap DEC_grow.st1.fR7 ++ freshOf DEC_grow.st1.s8.heap DEC_grow.st1.s7.next DEC_grow.st1.s8.next)
kernel_rfl DEC_grow.st1.fb7 : footRB DEC_grow.st1.s7 DEC_grow.st1.s8 DEC_grow.st1.fR7 = true
kernel_rfl DEC_grow.st1.fc7 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s7.next && Nat.ble DEC_grow.st1.s8.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR7 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa8 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s8 :=
  DEC_grow.st1.fa7.step (stageFoot_ofRF DEC_grow.st1.fh7 DEC_grow.st1.fb7) (incl_of_footW DEC_grow.st1.fb7 DEC_grow.st1.fc7)

def DEC_grow.st1.fR8 : List (Nat × Nat) := [(2672322, 2672323), (3130497, 3130500), (3130563, 3130570), (3130886, 3130887), (3131296, 3131297), (3131331, 3131332), (3131366, 3131367), (3131391, 3131393), (3131404, 3131406), (3131566, 3131567), (3131610, 3131611), (3131691, 3131693), (3131694, 3131695)]
kernel_rfl DEC_grow.st1.fh8 : DEC_grow.st1.s9.heap = setAll DEC_grow.st1.s8.heap (rangesOf DEC_grow.st1.s9.heap DEC_grow.st1.fR8 ++ freshOf DEC_grow.st1.s9.heap DEC_grow.st1.s8.next DEC_grow.st1.s9.next)
kernel_rfl DEC_grow.st1.fb8 : footRB DEC_grow.st1.s8 DEC_grow.st1.s9 DEC_grow.st1.fR8 = true
kernel_rfl DEC_grow.st1.fc8 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s8.next && Nat.ble DEC_grow.st1.s9.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR8 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa9 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s9 :=
  DEC_grow.st1.fa8.step (stageFoot_ofRF DEC_grow.st1.fh8 DEC_grow.st1.fb8) (incl_of_footW DEC_grow.st1.fb8 DEC_grow.st1.fc8)

def DEC_grow.st1.fR9 : List (Nat × Nat) := [(3123795, 3123796), (3130458, 3130459), (3130525, 3130526), (3132114, 3132115), (3132172, 3132173), (3132178, 3132179), (3132184, 3132185), (3132438, 3132439), (3132459, 3132460), (3132509, 3132510), (3132527, 3132529), (3132568, 3132574), (3132664, 3132665)]
kernel_rfl DEC_grow.st1.fh9 : DEC_grow.st1.s10.heap = setAll DEC_grow.st1.s9.heap (rangesOf DEC_grow.st1.s10.heap DEC_grow.st1.fR9 ++ freshOf DEC_grow.st1.s10.heap DEC_grow.st1.s9.next DEC_grow.st1.s10.next)
kernel_rfl DEC_grow.st1.fb9 : footRB DEC_grow.st1.s9 DEC_grow.st1.s10 DEC_grow.st1.fR9 = true
kernel_rfl DEC_grow.st1.fc9 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s9.next && Nat.ble DEC_grow.st1.s10.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR9 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa10 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s10 :=
  DEC_grow.st1.fa9.step (stageFoot_ofRF DEC_grow.st1.fh9 DEC_grow.st1.fb9) (incl_of_footW DEC_grow.st1.fb9 DEC_grow.st1.fc9)

def DEC_grow.st1.fR10 : List (Nat × Nat) := [(2672331, 2672332), (2985606, 2985607), (2986035, 2986036), (3132890, 3132893), (3132938, 3132943), (3133132, 3133133), (3133257, 3133258), (3133343, 3133344), (3133432, 3133433), (3133470, 3133477), (3133516, 3133518), (3133570, 3133571)]
kernel_rfl DEC_grow.st1.fh10 : DEC_grow.st1.s11.heap = setAll DEC_grow.st1.s10.heap (rangesOf DEC_grow.st1.s11.heap DEC_grow.st1.fR10 ++ freshOf DEC_grow.st1.s11.heap DEC_grow.st1.s10.next DEC_grow.st1.s11.next)
kernel_rfl DEC_grow.st1.fb10 : footRB DEC_grow.st1.s10 DEC_grow.st1.s11 DEC_grow.st1.fR10 = true
kernel_rfl DEC_grow.st1.fc10 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s10.next && Nat.ble DEC_grow.st1.s11.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR10 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa11 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s11 :=
  DEC_grow.st1.fa10.step (stageFoot_ofRF DEC_grow.st1.fh10 DEC_grow.st1.fb10) (incl_of_footW DEC_grow.st1.fb10 DEC_grow.st1.fc10)

def DEC_grow.st1.fR11 : List (Nat × Nat) := [(3123795, 3123796), (3132830, 3132831), (3132918, 3132919), (3134332, 3134333), (3134386, 3134387), (3134392, 3134393), (3134398, 3134399), (3134406, 3134407), (3134420, 3134421), (3134621, 3134622), (3134642, 3134646)]
kernel_rfl DEC_grow.st1.fh11 : DEC_grow.st1.s12.heap = setAll DEC_grow.st1.s11.heap (rangesOf DEC_grow.st1.s12.heap DEC_grow.st1.fR11 ++ freshOf DEC_grow.st1.s12.heap DEC_grow.st1.s11.next DEC_grow.st1.s12.next)
kernel_rfl DEC_grow.st1.fb11 : footRB DEC_grow.st1.s11 DEC_grow.st1.s12 DEC_grow.st1.fR11 = true
kernel_rfl DEC_grow.st1.fc11 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s11.next && Nat.ble DEC_grow.st1.s12.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR11 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa12 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s12 :=
  DEC_grow.st1.fa11.step (stageFoot_ofRF DEC_grow.st1.fh11 DEC_grow.st1.fb11) (incl_of_footW DEC_grow.st1.fb11 DEC_grow.st1.fc11)

def DEC_grow.st1.fR12 : List (Nat × Nat) := [(2672336, 2672337), (2987798, 2987799), (2988227, 2988228), (3135082, 3135085), (3135130, 3135135), (3135324, 3135325), (3135449, 3135450), (3135535, 3135536), (3135624, 3135625), (3135655, 3135669), (3135671, 3135673)]
kernel_rfl DEC_grow.st1.fh12 : DEC_grow.st1.s13.heap = setAll DEC_grow.st1.s12.heap (rangesOf DEC_grow.st1.s13.heap DEC_grow.st1.fR12 ++ freshOf DEC_grow.st1.s13.heap DEC_grow.st1.s12.next DEC_grow.st1.s13.next)
kernel_rfl DEC_grow.st1.fb12 : footRB DEC_grow.st1.s12 DEC_grow.st1.s13 DEC_grow.st1.fR12 = true
kernel_rfl DEC_grow.st1.fc12 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s12.next && Nat.ble DEC_grow.st1.s13.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR12 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa13 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s13 :=
  DEC_grow.st1.fa12.step (stageFoot_ofRF DEC_grow.st1.fh12 DEC_grow.st1.fb12) (incl_of_footW DEC_grow.st1.fb12 DEC_grow.st1.fc12)

def DEC_grow.st1.fR13 : List (Nat × Nat) := [(3123795, 3123796), (3135044, 3135045), (3135110, 3135111), (3136524, 3136525), (3136578, 3136579), (3136584, 3136585), (3136590, 3136591), (3136598, 3136599), (3136609, 3136613), (3136633, 3136634)]
kernel_rfl DEC_grow.st1.fh13 : DEC_grow.st1.s14.heap = setAll DEC_grow.st1.s13.heap (rangesOf DEC_grow.st1.s14.heap DEC_grow.st1.fR13 ++ freshOf DEC_grow.st1.s14.heap DEC_grow.st1.s13.next DEC_grow.st1.s14.next)
kernel_rfl DEC_grow.st1.fb13 : footRB DEC_grow.st1.s13 DEC_grow.st1.s14 DEC_grow.st1.fR13 = true
kernel_rfl DEC_grow.st1.fc13 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s13.next && Nat.ble DEC_grow.st1.s14.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR13 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa14 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s14 :=
  DEC_grow.st1.fa13.step (stageFoot_ofRF DEC_grow.st1.fh13 DEC_grow.st1.fb13) (incl_of_footW DEC_grow.st1.fb13 DEC_grow.st1.fc13)

def DEC_grow.st1.fR14 : List (Nat × Nat) := [(2672341, 2672342), (2990090, 2990091), (3137318, 3137322), (3137516, 3137517), (3137547, 3137548), (3137615, 3137616), (3137618, 3137628)]
kernel_rfl DEC_grow.st1.fh14 : DEC_grow.st1.s15.heap = setAll DEC_grow.st1.s14.heap (rangesOf DEC_grow.st1.s15.heap DEC_grow.st1.fR14 ++ freshOf DEC_grow.st1.s15.heap DEC_grow.st1.s14.next DEC_grow.st1.s15.next)
kernel_rfl DEC_grow.st1.fb14 : footRB DEC_grow.st1.s14 DEC_grow.st1.s15 DEC_grow.st1.fR14 = true
kernel_rfl DEC_grow.st1.fc14 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s14.next && Nat.ble DEC_grow.st1.s15.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR14 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa15 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s15 :=
  DEC_grow.st1.fa14.step (stageFoot_ofRF DEC_grow.st1.fh14 DEC_grow.st1.fb14) (incl_of_footW DEC_grow.st1.fb14 DEC_grow.st1.fc14)

def DEC_grow.st1.fR15 : List (Nat × Nat) := [(2672341, 2672342), (2990519, 2990520), (3137274, 3137277), (3137322, 3137327), (3137741, 3137742), (3137827, 3137828), (3137916, 3137917), (3138288, 3138289), (3138294, 3138295), (3138614, 3138615)]
kernel_rfl DEC_grow.st1.fh15 : DEC_grow.st1.s16.heap = setAll DEC_grow.st1.s15.heap (rangesOf DEC_grow.st1.s16.heap DEC_grow.st1.fR15 ++ freshOf DEC_grow.st1.s16.heap DEC_grow.st1.s15.next DEC_grow.st1.s16.next)
kernel_rfl DEC_grow.st1.fb15 : footRB DEC_grow.st1.s15 DEC_grow.st1.s16 DEC_grow.st1.fR15 = true
kernel_rfl DEC_grow.st1.fc15 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s15.next && Nat.ble DEC_grow.st1.s16.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR15 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa16 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s16 :=
  DEC_grow.st1.fa15.step (stageFoot_ofRF DEC_grow.st1.fh15 DEC_grow.st1.fb15) (incl_of_footW DEC_grow.st1.fb15 DEC_grow.st1.fc15)

def DEC_grow.st1.fR16 : List (Nat × Nat) := [(4841, 4842), (3123795, 3123796), (3137236, 3137237), (3137302, 3137303), (3138916, 3138917), (3138970, 3138971), (3138976, 3138977), (3138982, 3138983), (3139236, 3139237), (3139257, 3139258), (3139307, 3139308), (3139552, 3139553)]
kernel_rfl DEC_grow.st1.fh16 : DEC_grow.st1.s17.heap = setAll DEC_grow.st1.s16.heap (rangesOf DEC_grow.st1.s17.heap DEC_grow.st1.fR16 ++ freshOf DEC_grow.st1.s17.heap DEC_grow.st1.s16.next DEC_grow.st1.s17.next)
kernel_rfl DEC_grow.st1.fb16 : footRB DEC_grow.st1.s16 DEC_grow.st1.s17 DEC_grow.st1.fR16 = true
kernel_rfl DEC_grow.st1.fc16 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s16.next && Nat.ble DEC_grow.st1.s17.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR16 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa17 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s17 :=
  DEC_grow.st1.fa16.step (stageFoot_ofRF DEC_grow.st1.fh16 DEC_grow.st1.fb16) (incl_of_footW DEC_grow.st1.fb16 DEC_grow.st1.fc16)

def DEC_grow.st1.fR17 : List (Nat × Nat) := [(2672353, 2672354), (2992574, 2992575), (2992626, 2992627), (3139667, 3139670), (3139733, 3139740), (3140056, 3140057), (3140466, 3140467), (3140501, 3140502), (3140536, 3140537), (3140561, 3140563), (3140569, 3140576), (3140607, 3140609)]
kernel_rfl DEC_grow.st1.fh17 : DEC_grow.st1.s18.heap = setAll DEC_grow.st1.s17.heap (rangesOf DEC_grow.st1.s18.heap DEC_grow.st1.fR17 ++ freshOf DEC_grow.st1.s18.heap DEC_grow.st1.s17.next DEC_grow.st1.s18.next)
kernel_rfl DEC_grow.st1.fb17 : footRB DEC_grow.st1.s17 DEC_grow.st1.s18 DEC_grow.st1.fR17 = true
kernel_rfl DEC_grow.st1.fc17 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s17.next && Nat.ble DEC_grow.st1.s18.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR17 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa18 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s18 :=
  DEC_grow.st1.fa17.step (stageFoot_ofRF DEC_grow.st1.fh17 DEC_grow.st1.fb17) (incl_of_footW DEC_grow.st1.fb17 DEC_grow.st1.fc17)

def DEC_grow.st1.fR18 : List (Nat × Nat) := [(3123795, 3123796), (3139628, 3139629), (3139695, 3139696), (3141284, 3141285), (3141342, 3141343), (3141348, 3141349), (3141354, 3141355), (3141362, 3141363), (3141376, 3141377), (3141577, 3141578), (3141608, 3141609)]
kernel_rfl DEC_grow.st1.fh18 : DEC_grow.st1.s19.heap = setAll DEC_grow.st1.s18.heap (rangesOf DEC_grow.st1.s19.heap DEC_grow.st1.fR18 ++ freshOf DEC_grow.st1.s19.heap DEC_grow.st1.s18.next DEC_grow.st1.s19.next)
kernel_rfl DEC_grow.st1.fb18 : footRB DEC_grow.st1.s18 DEC_grow.st1.s19 DEC_grow.st1.fR18 = true
kernel_rfl DEC_grow.st1.fc18 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s18.next && Nat.ble DEC_grow.st1.s19.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR18 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa19 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s19 :=
  DEC_grow.st1.fa18.step (stageFoot_ofRF DEC_grow.st1.fh18 DEC_grow.st1.fb18) (incl_of_footW DEC_grow.st1.fb18 DEC_grow.st1.fc18)

def DEC_grow.st1.fR19 : List (Nat × Nat) := [(2672362, 2672363), (2994680, 2994681), (2995109, 2995110), (3142105, 3142112), (3142302, 3142303), (3142527, 3142528), (3142540, 3142541), (3142592, 3142594), (3142595, 3142596)]
kernel_rfl DEC_grow.st1.fh19 : DEC_grow.st1.s20.heap = setAll DEC_grow.st1.s19.heap (rangesOf DEC_grow.st1.s20.heap DEC_grow.st1.fR19 ++ freshOf DEC_grow.st1.s20.heap DEC_grow.st1.s19.next DEC_grow.st1.s20.next)
kernel_rfl DEC_grow.st1.fb19 : footRB DEC_grow.st1.s19 DEC_grow.st1.s20 DEC_grow.st1.fR19 = true
kernel_rfl DEC_grow.st1.fc19 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s19.next && Nat.ble DEC_grow.st1.s20.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR19 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa20 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s20 :=
  DEC_grow.st1.fa19.step (stageFoot_ofRF DEC_grow.st1.fh19 DEC_grow.st1.fb19) (incl_of_footW DEC_grow.st1.fb19 DEC_grow.st1.fc19)

def DEC_grow.st1.fR20 : List (Nat × Nat) := [(3123795, 3123796), (3142000, 3142001), (3142060, 3142063), (3142088, 3142089), (3142112, 3142113), (3143519, 3143520), (3143544, 3143545), (3143612, 3143613), (3143615, 3143625)]
kernel_rfl DEC_grow.st1.fh20 : DEC_grow.st1.s21.heap = setAll DEC_grow.st1.s20.heap (rangesOf DEC_grow.st1.s21.heap DEC_grow.st1.fR20 ++ freshOf DEC_grow.st1.s21.heap DEC_grow.st1.s20.next DEC_grow.st1.s21.next)
kernel_rfl DEC_grow.st1.fb20 : footRB DEC_grow.st1.s20 DEC_grow.st1.s21 DEC_grow.st1.fR20 = true
kernel_rfl DEC_grow.st1.fc20 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s20.next && Nat.ble DEC_grow.st1.s21.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR20 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa21 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s21 :=
  DEC_grow.st1.fa20.step (stageFoot_ofRF DEC_grow.st1.fh20 DEC_grow.st1.fb20) (incl_of_footW DEC_grow.st1.fb20 DEC_grow.st1.fc20)

def DEC_grow.st1.fR21 : List (Nat × Nat) := [(2672367, 2672368), (2997072, 2997073), (3144495, 3144500), (3144536, 3144537), (3144568, 3144570), (3144573, 3144574)]
kernel_rfl DEC_grow.st1.fh21 : DEC_grow.st1.s22.heap = setAll DEC_grow.st1.s21.heap (rangesOf DEC_grow.st1.s22.heap DEC_grow.st1.fR21 ++ freshOf DEC_grow.st1.s22.heap DEC_grow.st1.s21.next DEC_grow.st1.s22.next)
kernel_rfl DEC_grow.st1.fb21 : footRB DEC_grow.st1.s21 DEC_grow.st1.s22 DEC_grow.st1.fR21 = true
kernel_rfl DEC_grow.st1.fc21 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s21.next && Nat.ble DEC_grow.st1.s22.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR21 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa22 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s22 :=
  DEC_grow.st1.fa21.step (stageFoot_ofRF DEC_grow.st1.fh21 DEC_grow.st1.fb21) (incl_of_footW DEC_grow.st1.fb21 DEC_grow.st1.fc21)

def DEC_grow.st1.fR22 : List (Nat × Nat) := [(2672367, 2672368), (2997501, 2997502), (3144452, 3144455), (3144500, 3144505), (3144694, 3144695), (3144919, 3144920), (3145005, 3145006), (3145094, 3145095), (3145137, 3145139), (3145460, 3145461), (3145466, 3145467), (3145472, 3145473), (3145501, 3145503), (3145547, 3145548), (3145591, 3145592), (3145605, 3145615)]
kernel_rfl DEC_grow.st1.fh22 : DEC_grow.st1.s23.heap = setAll DEC_grow.st1.s22.heap (rangesOf DEC_grow.st1.s23.heap DEC_grow.st1.fR22 ++ freshOf DEC_grow.st1.s23.heap DEC_grow.st1.s22.next DEC_grow.st1.s23.next)
kernel_rfl DEC_grow.st1.fb22 : footRB DEC_grow.st1.s22 DEC_grow.st1.s23 DEC_grow.st1.fR22 = true
kernel_rfl DEC_grow.st1.fc22 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s22.next && Nat.ble DEC_grow.st1.s23.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR22 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa23 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s23 :=
  DEC_grow.st1.fa22.step (stageFoot_ofRF DEC_grow.st1.fh22 DEC_grow.st1.fb22) (incl_of_footW DEC_grow.st1.fb22 DEC_grow.st1.fc22)

def DEC_grow.st1.fR23 : List (Nat × Nat) := [(3123795, 3123796), (3144414, 3144415), (3144480, 3144481), (3146094, 3146095), (3146148, 3146149), (3146154, 3146155), (3146160, 3146161), (3146414, 3146415), (3146435, 3146436), (3146485, 3146486), (3146503, 3146505), (3146537, 3146538), (3146540, 3146550)]
kernel_rfl DEC_grow.st1.fh23 : DEC_grow.st1.s24.heap = setAll DEC_grow.st1.s23.heap (rangesOf DEC_grow.st1.s24.heap DEC_grow.st1.fR23 ++ freshOf DEC_grow.st1.s24.heap DEC_grow.st1.s23.next DEC_grow.st1.s24.next)
kernel_rfl DEC_grow.st1.fb23 : footRB DEC_grow.st1.s23 DEC_grow.st1.s24 DEC_grow.st1.fR23 = true
kernel_rfl DEC_grow.st1.fc23 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s23.next && Nat.ble DEC_grow.st1.s24.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR23 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa24 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s24 :=
  DEC_grow.st1.fa23.step (stageFoot_ofRF DEC_grow.st1.fh23 DEC_grow.st1.fb23) (incl_of_footW DEC_grow.st1.fb23 DEC_grow.st1.fc23)

def DEC_grow.st1.fR24 : List (Nat × Nat) := [(2672372, 2672373), (2999464, 2999465), (2999893, 2999894), (3146844, 3146845), (3146892, 3146897), (3147086, 3147087), (3147311, 3147312), (3147397, 3147398), (3147486, 3147487), (3147520, 3147531)]
kernel_rfl DEC_grow.st1.fh24 : DEC_grow.st1.s25.heap = setAll DEC_grow.st1.s24.heap (rangesOf DEC_grow.st1.s25.heap DEC_grow.st1.fR24 ++ freshOf DEC_grow.st1.s25.heap DEC_grow.st1.s24.next DEC_grow.st1.s25.next)
kernel_rfl DEC_grow.st1.fb24 : footRB DEC_grow.st1.s24 DEC_grow.st1.s25 DEC_grow.st1.fR24 = true
kernel_rfl DEC_grow.st1.fc24 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s24.next && Nat.ble DEC_grow.st1.s25.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR24 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa25 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s25 :=
  DEC_grow.st1.fa24.step (stageFoot_ofRF DEC_grow.st1.fh24 DEC_grow.st1.fb24) (incl_of_footW DEC_grow.st1.fb24 DEC_grow.st1.fc24)

def DEC_grow.st1.fR25 : List (Nat × Nat) := [(3123795, 3123796), (3146806, 3146807), (3146845, 3146847), (3146872, 3146873), (3148486, 3148487), (3148510, 3148520)]
kernel_rfl DEC_grow.st1.fh25 : DEC_grow.st1.s26.heap = setAll DEC_grow.st1.s25.heap (rangesOf DEC_grow.st1.s26.heap DEC_grow.st1.fR25 ++ freshOf DEC_grow.st1.s26.heap DEC_grow.st1.s25.next DEC_grow.st1.s26.next)
kernel_rfl DEC_grow.st1.fb25 : footRB DEC_grow.st1.s25 DEC_grow.st1.s26 DEC_grow.st1.fR25 = true
kernel_rfl DEC_grow.st1.fc25 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s25.next && Nat.ble DEC_grow.st1.s26.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR25 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa26 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s26 :=
  DEC_grow.st1.fa25.step (stageFoot_ofRF DEC_grow.st1.fh25 DEC_grow.st1.fb25) (incl_of_footW DEC_grow.st1.fb25 DEC_grow.st1.fc25)

def DEC_grow.st1.fR26 : List (Nat × Nat) := [(4841, 4842), (2672384, 2672385), (3001948, 3001949), (3002000, 3002001), (3149297, 3149303), (3149436, 3149437), (3149470, 3149471), (3149496, 3149497), (3149507, 3149508)]
kernel_rfl DEC_grow.st1.fh26 : DEC_grow.st1.s27.heap = setAll DEC_grow.st1.s26.heap (rangesOf DEC_grow.st1.s27.heap DEC_grow.st1.fR26 ++ freshOf DEC_grow.st1.s27.heap DEC_grow.st1.s26.next DEC_grow.st1.s27.next)
kernel_rfl DEC_grow.st1.fb26 : footRB DEC_grow.st1.s26 DEC_grow.st1.s27 DEC_grow.st1.fR26 = true
kernel_rfl DEC_grow.st1.fc26 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s26.next && Nat.ble DEC_grow.st1.s27.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR26 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa27 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s27 :=
  DEC_grow.st1.fa26.step (stageFoot_ofRF DEC_grow.st1.fh26 DEC_grow.st1.fb26) (incl_of_footW DEC_grow.st1.fb26 DEC_grow.st1.fc26)

def DEC_grow.st1.fR27 : List (Nat × Nat) := [(3149237, 3149240), (3149303, 3149310), (3149626, 3149627), (3150036, 3150037), (3150071, 3150072), (3150106, 3150107), (3150131, 3150133), (3150538, 3150540), (3150541, 3150542)]
kernel_rfl DEC_grow.st1.fh27 : DEC_grow.st1.s28.heap = setAll DEC_grow.st1.s27.heap (rangesOf DEC_grow.st1.s28.heap DEC_grow.st1.fR27 ++ freshOf DEC_grow.st1.s28.heap DEC_grow.st1.s27.next DEC_grow.st1.s28.next)
kernel_rfl DEC_grow.st1.fb27 : footRB DEC_grow.st1.s27 DEC_grow.st1.s28 DEC_grow.st1.fR27 = true
kernel_rfl DEC_grow.st1.fc27 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s27.next && Nat.ble DEC_grow.st1.s28.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR27 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa28 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s28 :=
  DEC_grow.st1.fa27.step (stageFoot_ofRF DEC_grow.st1.fh27 DEC_grow.st1.fb27) (incl_of_footW DEC_grow.st1.fb27 DEC_grow.st1.fc27)

def DEC_grow.st1.fR28 : List (Nat × Nat) := [(3123795, 3123796), (3149198, 3149199), (3149265, 3149266), (3150854, 3150855), (3150912, 3150913), (3150918, 3150919), (3150924, 3150925), (3151178, 3151179), (3151199, 3151200), (3151249, 3151250), (3151272, 3151273), (3151415, 3151416), (3151493, 3151494), (3151498, 3151499)]
kernel_rfl DEC_grow.st1.fh28 : DEC_grow.st1.s29.heap = setAll DEC_grow.st1.s28.heap (rangesOf DEC_grow.st1.s29.heap DEC_grow.st1.fR28 ++ freshOf DEC_grow.st1.s29.heap DEC_grow.st1.s28.next DEC_grow.st1.s29.next)
kernel_rfl DEC_grow.st1.fb28 : footRB DEC_grow.st1.s28 DEC_grow.st1.s29 DEC_grow.st1.fR28 = true
kernel_rfl DEC_grow.st1.fc28 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s28.next && Nat.ble DEC_grow.st1.s29.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR28 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa29 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s29 :=
  DEC_grow.st1.fa28.step (stageFoot_ofRF DEC_grow.st1.fh28 DEC_grow.st1.fb28) (incl_of_footW DEC_grow.st1.fb28 DEC_grow.st1.fc28)

def DEC_grow.st1.fR29 : List (Nat × Nat) := [(2672393, 2672394), (3004058, 3004059), (3004487, 3004488), (3151634, 3151637), (3151682, 3151687), (3151876, 3151877), (3152101, 3152102), (3152187, 3152188), (3152276, 3152277), (3152314, 3152321), (3152361, 3152362), (3152414, 3152415), (3152572, 3152577)]
kernel_rfl DEC_grow.st1.fh29 : DEC_grow.st1.s30.heap = setAll DEC_grow.st1.s29.heap (rangesOf DEC_grow.st1.s30.heap DEC_grow.st1.fR29 ++ freshOf DEC_grow.st1.s30.heap DEC_grow.st1.s29.next DEC_grow.st1.s30.next)
kernel_rfl DEC_grow.st1.fb29 : footRB DEC_grow.st1.s29 DEC_grow.st1.s30 DEC_grow.st1.fR29 = true
kernel_rfl DEC_grow.st1.fc29 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s29.next && Nat.ble DEC_grow.st1.s30.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR29 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa30 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s30 :=
  DEC_grow.st1.fa29.step (stageFoot_ofRF DEC_grow.st1.fh29 DEC_grow.st1.fb29) (incl_of_footW DEC_grow.st1.fb29 DEC_grow.st1.fc29)

def DEC_grow.st1.fR30 : List (Nat × Nat) := [(3123795, 3123796), (3151574, 3151575), (3151662, 3151663), (3153276, 3153277), (3153330, 3153331), (3153336, 3153337), (3153342, 3153343), (3153350, 3153351), (3153363, 3153365), (3153419, 3153420), (3153447, 3153448), (3153450, 3153460)]
kernel_rfl DEC_grow.st1.fh30 : DEC_grow.st1.s31.heap = setAll DEC_grow.st1.s30.heap (rangesOf DEC_grow.st1.s31.heap DEC_grow.st1.fR30 ++ freshOf DEC_grow.st1.s31.heap DEC_grow.st1.s30.next DEC_grow.st1.s31.next)
kernel_rfl DEC_grow.st1.fb30 : footRB DEC_grow.st1.s30 DEC_grow.st1.s31 DEC_grow.st1.fR30 = true
kernel_rfl DEC_grow.st1.fc30 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s30.next && Nat.ble DEC_grow.st1.s31.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR30 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa31 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s31 :=
  DEC_grow.st1.fa30.step (stageFoot_ofRF DEC_grow.st1.fh30 DEC_grow.st1.fb30) (incl_of_footW DEC_grow.st1.fb30 DEC_grow.st1.fc30)

def DEC_grow.st1.fR31 : List (Nat × Nat) := [(2672398, 2672399), (3006450, 3006451), (3006879, 3006880), (3154070, 3154077), (3154268, 3154269), (3154457, 3154458)]
kernel_rfl DEC_grow.st1.fh31 : DEC_grow.st1.s32.heap = setAll DEC_grow.st1.s31.heap (rangesOf DEC_grow.st1.s32.heap DEC_grow.st1.fR31 ++ freshOf DEC_grow.st1.s32.heap DEC_grow.st1.s31.next DEC_grow.st1.s32.next)
kernel_rfl DEC_grow.st1.fb31 : footRB DEC_grow.st1.s31 DEC_grow.st1.s32 DEC_grow.st1.fR31 = true
kernel_rfl DEC_grow.st1.fc31 : (Nat.ble DEC_grow.st1.s0.next DEC_grow.st1.s31.next && Nat.ble DEC_grow.st1.s32.next DEC_grow.st1.s153.next && coverB DEC_grow.st1.fR31 DEC_grow.st1.wrR DEC_grow.st1.s0.next) = true
theorem DEC_grow.st1.fa32 : FootAcc DEC_grow.st1.wr DEC_grow.st1.s153 DEC_grow.st1.s0 DEC_grow.st1.s32 :=
  DEC_grow.st1.fa31.step (stageFoot_ofRF DEC_grow.st1.fh31 DEC_grow.st1.fb31) (incl_of_footW DEC_grow.st1.fb31 DEC_grow.st1.fc31)

end Host.Load.Run.Tpl

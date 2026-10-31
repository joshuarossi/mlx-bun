import host.sim.template.a4dec_fill.st1.H4
import host.sim.template.CallGen
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage Host.Ts.Sim.Template

/-! The footprint of stage `DEC_fill.st1`'s site template per stream state (`stageFoot_ofRF`, composed by `FootAcc`): each state's written ranges and fresh range,
its written addresses on the return state's written list `DEC_fill.st1.wr`. -/

/-- The written heap ranges below the start's counter. -/
def DEC_fill.st1.wrR : List (Nat × Nat) := [(4841, 4842), (2672300, 2672301), (2672305, 2672306), (2672310, 2672311), (2672322, 2672323), (2672331, 2672332), (2672336, 2672337), (2672341, 2672342), (2672353, 2672354), (2672362, 2672363), (2672367, 2672368), (2672372, 2672373), (2672384, 2672385), (2672393, 2672394), (2672398, 2672399), (2672403, 2672404), (2672415, 2672416), (2672424, 2672425), (2672429, 2672430), (2672434, 2672435), (2672446, 2672447), (2672455, 2672456), (2672460, 2672461), (2672465, 2672466), (2672477, 2672478), (2672486, 2672487), (2672491, 2672492), (2672496, 2672497), (2672508, 2672509), (2672517, 2672518), (2672522, 2672523), (2672527, 2672528), (2672539, 2672540), (2672548, 2672549), (2672553, 2672554), (2672558, 2672559), (2672570, 2672571), (2672579, 2672580), (2672584, 2672585), (2672589, 2672590), (2672601, 2672602), (2672610, 2672611), (2672615, 2672616), (2672620, 2672621), (2672632, 2672633), (2672641, 2672642), (2672646, 2672647), (2672651, 2672652), (2672663, 2672664), (2672672, 2672673), (2672677, 2672678), (2672682, 2672683), (2672694, 2672695), (2672703, 2672704), (2672708, 2672709), (2672713, 2672714), (2672725, 2672726), (2672734, 2672735), (2672739, 2672740), (2672744, 2672745), (2672756, 2672757), (2672765, 2672766), (2672770, 2672771), (2672775, 2672776), (2672787, 2672788), (2976628, 2976629), (2977057, 2977058), (2978924, 2978925), (2979353, 2979354), (2981216, 2981217), (2981645, 2981646), (2983600, 2983601), (2983652, 2983653), (2985606, 2985607), (2986035, 2986036), (2987798, 2987799), (2988227, 2988228), (2990090, 2990091), (2990519, 2990520), (2992574, 2992575), (2992626, 2992627), (2994680, 2994681), (2995109, 2995110), (2997072, 2997073), (2997501, 2997502), (2999464, 2999465), (2999893, 2999894), (3001948, 3001949), (3002000, 3002001), (3004058, 3004059), (3004487, 3004488), (3006450, 3006451), (3006879, 3006880), (3008846, 3008847), (3009275, 3009276), (3011330, 3011331), (3011382, 3011383), (3013440, 3013441), (3013869, 3013870), (3015836, 3015837), (3016265, 3016266), (3018232, 3018233), (3018661, 3018662), (3020720, 3020721), (3020772, 3020773), (3022826, 3022827), (3023255, 3023256), (3025218, 3025219), (3025647, 3025648), (3027610, 3027611), (3028039, 3028040), (3030094, 3030095), (3030146, 3030147), (3032200, 3032201), (3032629, 3032630), (3034492, 3034493), (3034921, 3034922), (3036884, 3036885), (3037313, 3037314), (3039368, 3039369), (3039420, 3039421), (3041474, 3041475), (3041903, 3041904), (3043866, 3043867), (3044295, 3044296), (3046262, 3046263), (3046691, 3046692), (3048746, 3048747), (3048798, 3048799), (3050856, 3050857), (3051285, 3051286), (3053252, 3053253), (3053681, 3053682), (3055648, 3055649), (3056077, 3056078), (3058132, 3058133), (3058184, 3058185), (3060238, 3060239), (3060667, 3060668), (3062630, 3062631), (3063059, 3063060), (3065022, 3065023), (3065451, 3065452), (3067506, 3067507), (3067558, 3067559), (3069612, 3069613), (3070041, 3070042), (3072004, 3072005), (3072433, 3072434), (3074396, 3074397), (3074825, 3074826), (3076880, 3076881), (3076932, 3076933), (3078986, 3078987), (3079415, 3079416), (3081378, 3081379), (3081807, 3081808), (3083774, 3083775), (3084203, 3084204), (3086262, 3086263), (3086314, 3086315), (3088372, 3088373), (3088801, 3088802), (3090768, 3090769), (3091197, 3091198), (3093164, 3093165), (3093593, 3093594), (3095648, 3095649), (3095700, 3095701), (3097754, 3097755), (3098183, 3098184), (3100046, 3100047), (3100475, 3100476), (3102238, 3102239), (3102667, 3102668), (3104626, 3104627), (3104678, 3104679), (3106536, 3106537), (3106965, 3106966), (3108632, 3108633), (3109061, 3109062), (3110828, 3110829), (3111257, 3111258), (3113316, 3113317), (3113368, 3113369), (3115226, 3115227), (3115655, 3115656), (3117422, 3117423), (3117851, 3117852), (3119518, 3119519), (3119947, 3119948), (3122002, 3122003), (3122054, 3122055)]
/-- The written and fresh addresses of the return state. -/
noncomputable def DEC_fill.st1.wr : List Nat := footW DEC_fill.st1.s150 DEC_fill.st1.wrR DEC_fill.st1.s0.next

theorem DEC_fill.st1.fa0 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s0 := FootAcc.start _ _ _

def DEC_fill.st1.fR0 : List (Nat × Nat) := [(2672300, 2672301), (2976628, 2976629)]
kernel_rfl DEC_fill.st1.fh0 : DEC_fill.st1.s1.heap = setAll DEC_fill.st1.s0.heap (rangesOf DEC_fill.st1.s1.heap DEC_fill.st1.fR0 ++ freshOf DEC_fill.st1.s1.heap DEC_fill.st1.s0.next DEC_fill.st1.s1.next)
kernel_rfl DEC_fill.st1.fb0 : footRB DEC_fill.st1.s0 DEC_fill.st1.s1 DEC_fill.st1.fR0 = true
kernel_rfl DEC_fill.st1.fc0 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s0.next && Nat.ble DEC_fill.st1.s1.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR0 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa1 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s1 :=
  DEC_fill.st1.fa0.step (stageFoot_ofRF DEC_fill.st1.fh0 DEC_fill.st1.fb0) (incl_of_footW DEC_fill.st1.fb0 DEC_fill.st1.fc0)

def DEC_fill.st1.fR1 : List (Nat × Nat) := [(2672300, 2672301), (2977057, 2977058), (3123816, 3123819), (3123864, 3123869), (3123958, 3123959), (3124083, 3124084), (3124169, 3124170), (3124258, 3124259), (3124301, 3124303), (3124624, 3124625), (3124630, 3124631), (3124636, 3124637), (3124664, 3124667), (3124711, 3124712), (3124755, 3124756)]
kernel_rfl DEC_fill.st1.fh1 : DEC_fill.st1.s2.heap = setAll DEC_fill.st1.s1.heap (rangesOf DEC_fill.st1.s2.heap DEC_fill.st1.fR1 ++ freshOf DEC_fill.st1.s2.heap DEC_fill.st1.s1.next DEC_fill.st1.s2.next)
kernel_rfl DEC_fill.st1.fb1 : footRB DEC_fill.st1.s1 DEC_fill.st1.s2 DEC_fill.st1.fR1 = true
kernel_rfl DEC_fill.st1.fc1 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s1.next && Nat.ble DEC_fill.st1.s2.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR1 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa2 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s2 :=
  DEC_fill.st1.fa1.step (stageFoot_ofRF DEC_fill.st1.fh1 DEC_fill.st1.fb1) (incl_of_footW DEC_fill.st1.fb1 DEC_fill.st1.fc1)

def DEC_fill.st1.fR2 : List (Nat × Nat) := [(3123774, 3123775), (3123795, 3123796), (3123844, 3123845), (3125158, 3125159), (3125212, 3125213), (3125218, 3125219), (3125224, 3125225), (3125478, 3125479), (3125499, 3125500), (3125549, 3125550), (3125571, 3125573), (3125605, 3125606), (3125608, 3125618), (3125690, 3125691)]
kernel_rfl DEC_fill.st1.fh2 : DEC_fill.st1.s3.heap = setAll DEC_fill.st1.s2.heap (rangesOf DEC_fill.st1.s3.heap DEC_fill.st1.fR2 ++ freshOf DEC_fill.st1.s3.heap DEC_fill.st1.s2.next DEC_fill.st1.s3.next)
kernel_rfl DEC_fill.st1.fb2 : footRB DEC_fill.st1.s2 DEC_fill.st1.s3 DEC_fill.st1.fR2 = true
kernel_rfl DEC_fill.st1.fc2 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s2.next && Nat.ble DEC_fill.st1.s3.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR2 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa3 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s3 :=
  DEC_fill.st1.fa2.step (stageFoot_ofRF DEC_fill.st1.fh2 DEC_fill.st1.fb2) (incl_of_footW DEC_fill.st1.fb2 DEC_fill.st1.fc2)

def DEC_fill.st1.fR3 : List (Nat × Nat) := [(2672305, 2672306), (2978924, 2978925), (2979353, 2979354), (3125912, 3125915), (3125960, 3125965), (3126154, 3126155), (3126379, 3126380), (3126465, 3126466), (3126554, 3126555), (3126592, 3126599), (3126638, 3126640), (3126692, 3126693), (3126715, 3126718), (3126721, 3126722)]
kernel_rfl DEC_fill.st1.fh3 : DEC_fill.st1.s4.heap = setAll DEC_fill.st1.s3.heap (rangesOf DEC_fill.st1.s4.heap DEC_fill.st1.fR3 ++ freshOf DEC_fill.st1.s4.heap DEC_fill.st1.s3.next DEC_fill.st1.s4.next)
kernel_rfl DEC_fill.st1.fb3 : footRB DEC_fill.st1.s3 DEC_fill.st1.s4 DEC_fill.st1.fR3 = true
kernel_rfl DEC_fill.st1.fc3 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s3.next && Nat.ble DEC_fill.st1.s4.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR3 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa4 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s4 :=
  DEC_fill.st1.fa3.step (stageFoot_ofRF DEC_fill.st1.fh3 DEC_fill.st1.fb3) (incl_of_footW DEC_fill.st1.fb3 DEC_fill.st1.fc3)

def DEC_fill.st1.fR4 : List (Nat × Nat) := [(3123795, 3123796), (3125874, 3125875), (3125940, 3125941), (3127454, 3127455), (3127508, 3127509), (3127514, 3127515), (3127520, 3127521), (3127528, 3127529), (3127541, 3127543), (3127597, 3127598), (3127625, 3127626), (3127628, 3127638)]
kernel_rfl DEC_fill.st1.fh4 : DEC_fill.st1.s5.heap = setAll DEC_fill.st1.s4.heap (rangesOf DEC_fill.st1.s5.heap DEC_fill.st1.fR4 ++ freshOf DEC_fill.st1.s5.heap DEC_fill.st1.s4.next DEC_fill.st1.s5.next)
kernel_rfl DEC_fill.st1.fb4 : footRB DEC_fill.st1.s4 DEC_fill.st1.s5 DEC_fill.st1.fR4 = true
kernel_rfl DEC_fill.st1.fc4 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s4.next && Nat.ble DEC_fill.st1.s5.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR4 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa5 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s5 :=
  DEC_fill.st1.fa4.step (stageFoot_ofRF DEC_fill.st1.fh4 DEC_fill.st1.fb4) (incl_of_footW DEC_fill.st1.fb4 DEC_fill.st1.fc4)

def DEC_fill.st1.fR5 : List (Nat × Nat) := [(2672310, 2672311), (2981216, 2981217), (2981645, 2981646), (3128248, 3128255), (3128446, 3128447), (3128635, 3128636)]
kernel_rfl DEC_fill.st1.fh5 : DEC_fill.st1.s6.heap = setAll DEC_fill.st1.s5.heap (rangesOf DEC_fill.st1.s6.heap DEC_fill.st1.fR5 ++ freshOf DEC_fill.st1.s6.heap DEC_fill.st1.s5.next DEC_fill.st1.s6.next)
kernel_rfl DEC_fill.st1.fb5 : footRB DEC_fill.st1.s5 DEC_fill.st1.s6 DEC_fill.st1.fR5 = true
kernel_rfl DEC_fill.st1.fc5 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s5.next && Nat.ble DEC_fill.st1.s6.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR5 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa6 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s6 :=
  DEC_fill.st1.fa5.step (stageFoot_ofRF DEC_fill.st1.fh5 DEC_fill.st1.fb5) (incl_of_footW DEC_fill.st1.fb5 DEC_fill.st1.fc5)

def DEC_fill.st1.fR6 : List (Nat × Nat) := [(3123795, 3123796), (3128166, 3128167), (3128204, 3128207), (3128232, 3128233), (3128255, 3128257), (3129630, 3129631), (3129655, 3129657), (3129658, 3129659)]
kernel_rfl DEC_fill.st1.fh6 : DEC_fill.st1.s7.heap = setAll DEC_fill.st1.s6.heap (rangesOf DEC_fill.st1.s7.heap DEC_fill.st1.fR6 ++ freshOf DEC_fill.st1.s7.heap DEC_fill.st1.s6.next DEC_fill.st1.s7.next)
kernel_rfl DEC_fill.st1.fb6 : footRB DEC_fill.st1.s6 DEC_fill.st1.s7 DEC_fill.st1.fR6 = true
kernel_rfl DEC_fill.st1.fc6 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s6.next && Nat.ble DEC_fill.st1.s7.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR6 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa7 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s7 :=
  DEC_fill.st1.fa6.step (stageFoot_ofRF DEC_fill.st1.fh6 DEC_fill.st1.fb6) (incl_of_footW DEC_fill.st1.fb6 DEC_fill.st1.fc6)

def DEC_fill.st1.fR7 : List (Nat × Nat) := [(4841, 4842), (2672322, 2672323), (2983600, 2983601), (2983652, 2983653), (3130555, 3130564), (3130587, 3130588), (3130639, 3130641), (3130642, 3130643)]
kernel_rfl DEC_fill.st1.fh7 : DEC_fill.st1.s8.heap = setAll DEC_fill.st1.s7.heap (rangesOf DEC_fill.st1.s8.heap DEC_fill.st1.fR7 ++ freshOf DEC_fill.st1.s8.heap DEC_fill.st1.s7.next DEC_fill.st1.s8.next)
kernel_rfl DEC_fill.st1.fb7 : footRB DEC_fill.st1.s7 DEC_fill.st1.s8 DEC_fill.st1.fR7 = true
kernel_rfl DEC_fill.st1.fc7 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s7.next && Nat.ble DEC_fill.st1.s8.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR7 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa8 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s8 :=
  DEC_fill.st1.fa7.step (stageFoot_ofRF DEC_fill.st1.fh7 DEC_fill.st1.fb7) (incl_of_footW DEC_fill.st1.fb7 DEC_fill.st1.fc7)

def DEC_fill.st1.fR8 : List (Nat × Nat) := [(3130497, 3130500), (3130564, 3130570), (3130886, 3130887), (3131296, 3131297), (3131331, 3131332), (3131366, 3131367), (3131610, 3131611), (3131659, 3131660)]
kernel_rfl DEC_fill.st1.fh8 : DEC_fill.st1.s9.heap = setAll DEC_fill.st1.s8.heap (rangesOf DEC_fill.st1.s9.heap DEC_fill.st1.fR8 ++ freshOf DEC_fill.st1.s9.heap DEC_fill.st1.s8.next DEC_fill.st1.s9.next)
kernel_rfl DEC_fill.st1.fb8 : footRB DEC_fill.st1.s8 DEC_fill.st1.s9 DEC_fill.st1.fR8 = true
kernel_rfl DEC_fill.st1.fc8 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s8.next && Nat.ble DEC_fill.st1.s9.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR8 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa9 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s9 :=
  DEC_fill.st1.fa8.step (stageFoot_ofRF DEC_fill.st1.fh8 DEC_fill.st1.fb8) (incl_of_footW DEC_fill.st1.fb8 DEC_fill.st1.fc8)

def DEC_fill.st1.fR9 : List (Nat × Nat) := [(2672331, 2672332), (2985606, 2985607), (3123795, 3123796), (3130458, 3130459), (3130525, 3130526), (3131918, 3131919), (3131976, 3131977), (3131982, 3131983), (3132589, 3132590), (3132624, 3132626), (3132627, 3132628)]
kernel_rfl DEC_fill.st1.fh9 : DEC_fill.st1.s10.heap = setAll DEC_fill.st1.s9.heap (rangesOf DEC_fill.st1.s10.heap DEC_fill.st1.fR9 ++ freshOf DEC_fill.st1.s10.heap DEC_fill.st1.s9.next DEC_fill.st1.s10.next)
kernel_rfl DEC_fill.st1.fb9 : footRB DEC_fill.st1.s9 DEC_fill.st1.s10 DEC_fill.st1.fR9 = true
kernel_rfl DEC_fill.st1.fc9 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s9.next && Nat.ble DEC_fill.st1.s10.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR9 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa10 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s10 :=
  DEC_fill.st1.fa9.step (stageFoot_ofRF DEC_fill.st1.fh9 DEC_fill.st1.fb9) (incl_of_footW DEC_fill.st1.fb9 DEC_fill.st1.fc9)

def DEC_fill.st1.fR10 : List (Nat × Nat) := [(2672331, 2672332), (2986035, 2986036), (3132694, 3132697), (3132742, 3132747), (3132936, 3132937), (3133061, 3133062), (3133147, 3133148), (3133236, 3133237), (3133279, 3133281), (3133602, 3133603), (3133608, 3133609), (3133614, 3133615), (3133640, 3133645), (3133689, 3133690), (3133703, 3133713)]
kernel_rfl DEC_fill.st1.fh10 : DEC_fill.st1.s11.heap = setAll DEC_fill.st1.s10.heap (rangesOf DEC_fill.st1.s11.heap DEC_fill.st1.fR10 ++ freshOf DEC_fill.st1.s11.heap DEC_fill.st1.s10.next DEC_fill.st1.s11.next)
kernel_rfl DEC_fill.st1.fb10 : footRB DEC_fill.st1.s10 DEC_fill.st1.s11 DEC_fill.st1.fR10 = true
kernel_rfl DEC_fill.st1.fc10 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s10.next && Nat.ble DEC_fill.st1.s11.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR10 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa11 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s11 :=
  DEC_fill.st1.fa10.step (stageFoot_ofRF DEC_fill.st1.fh10 DEC_fill.st1.fb10) (incl_of_footW DEC_fill.st1.fb10 DEC_fill.st1.fc10)

def DEC_fill.st1.fR11 : List (Nat × Nat) := [(3123795, 3123796), (3132634, 3132635), (3132722, 3132723), (3134136, 3134137), (3134190, 3134191), (3134196, 3134197), (3134202, 3134203), (3134456, 3134457), (3134477, 3134478), (3134527, 3134528), (3134545, 3134547), (3134579, 3134580), (3134582, 3134592)]
kernel_rfl DEC_fill.st1.fh11 : DEC_fill.st1.s12.heap = setAll DEC_fill.st1.s11.heap (rangesOf DEC_fill.st1.s12.heap DEC_fill.st1.fR11 ++ freshOf DEC_fill.st1.s12.heap DEC_fill.st1.s11.next DEC_fill.st1.s12.next)
kernel_rfl DEC_fill.st1.fb11 : footRB DEC_fill.st1.s11 DEC_fill.st1.s12 DEC_fill.st1.fR11 = true
kernel_rfl DEC_fill.st1.fc11 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s11.next && Nat.ble DEC_fill.st1.s12.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR11 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa12 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s12 :=
  DEC_fill.st1.fa11.step (stageFoot_ofRF DEC_fill.st1.fh11 DEC_fill.st1.fb11) (incl_of_footW DEC_fill.st1.fb11 DEC_fill.st1.fc11)

def DEC_fill.st1.fR12 : List (Nat × Nat) := [(2672336, 2672337), (2987798, 2987799), (2988227, 2988228), (3134886, 3134889), (3134934, 3134939), (3135128, 3135129), (3135253, 3135254), (3135339, 3135340), (3135428, 3135429), (3135466, 3135473), (3135512, 3135514), (3135566, 3135567), (3135648, 3135649), (3135692, 3135695), (3135696, 3135697)]
kernel_rfl DEC_fill.st1.fh12 : DEC_fill.st1.s13.heap = setAll DEC_fill.st1.s12.heap (rangesOf DEC_fill.st1.s13.heap DEC_fill.st1.fR12 ++ freshOf DEC_fill.st1.s13.heap DEC_fill.st1.s12.next DEC_fill.st1.s13.next)
kernel_rfl DEC_fill.st1.fb12 : footRB DEC_fill.st1.s12 DEC_fill.st1.s13 DEC_fill.st1.fR12 = true
kernel_rfl DEC_fill.st1.fc12 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s12.next && Nat.ble DEC_fill.st1.s13.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR12 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa13 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s13 :=
  DEC_fill.st1.fa12.step (stageFoot_ofRF DEC_fill.st1.fh12 DEC_fill.st1.fb12) (incl_of_footW DEC_fill.st1.fb12 DEC_fill.st1.fc12)

def DEC_fill.st1.fR13 : List (Nat × Nat) := [(3123795, 3123796), (3134848, 3134849), (3134914, 3134915), (3136328, 3136329), (3136382, 3136383), (3136388, 3136389), (3136394, 3136395), (3136402, 3136403), (3136415, 3136417), (3136471, 3136472), (3136612, 3136613)]
kernel_rfl DEC_fill.st1.fh13 : DEC_fill.st1.s14.heap = setAll DEC_fill.st1.s13.heap (rangesOf DEC_fill.st1.s14.heap DEC_fill.st1.fR13 ++ freshOf DEC_fill.st1.s14.heap DEC_fill.st1.s13.next DEC_fill.st1.s14.next)
kernel_rfl DEC_fill.st1.fb13 : footRB DEC_fill.st1.s13 DEC_fill.st1.s14 DEC_fill.st1.fR13 = true
kernel_rfl DEC_fill.st1.fc13 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s13.next && Nat.ble DEC_fill.st1.s14.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR13 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa14 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s14 :=
  DEC_fill.st1.fa13.step (stageFoot_ofRF DEC_fill.st1.fh13 DEC_fill.st1.fb13) (incl_of_footW DEC_fill.st1.fb13 DEC_fill.st1.fc13)

def DEC_fill.st1.fR14 : List (Nat × Nat) := [(2672341, 2672342), (2990090, 2990091), (2990519, 2990520), (3137123, 3137130), (3137320, 3137321), (3137545, 3137546), (3137558, 3137559), (3137610, 3137612), (3137613, 3137614)]
kernel_rfl DEC_fill.st1.fh14 : DEC_fill.st1.s15.heap = setAll DEC_fill.st1.s14.heap (rangesOf DEC_fill.st1.s15.heap DEC_fill.st1.fR14 ++ freshOf DEC_fill.st1.s15.heap DEC_fill.st1.s14.next DEC_fill.st1.s15.next)
kernel_rfl DEC_fill.st1.fb14 : footRB DEC_fill.st1.s14 DEC_fill.st1.s15 DEC_fill.st1.fR14 = true
kernel_rfl DEC_fill.st1.fc14 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s14.next && Nat.ble DEC_fill.st1.s15.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR14 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa15 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s15 :=
  DEC_fill.st1.fa14.step (stageFoot_ofRF DEC_fill.st1.fh14 DEC_fill.st1.fb14) (incl_of_footW DEC_fill.st1.fb14 DEC_fill.st1.fc14)

def DEC_fill.st1.fR15 : List (Nat × Nat) := [(3123795, 3123796), (3137040, 3137041), (3137078, 3137081), (3137106, 3137107), (3137130, 3137131), (3138537, 3138538), (3138562, 3138563), (3138594, 3138595)]
kernel_rfl DEC_fill.st1.fh15 : DEC_fill.st1.s16.heap = setAll DEC_fill.st1.s15.heap (rangesOf DEC_fill.st1.s16.heap DEC_fill.st1.fR15 ++ freshOf DEC_fill.st1.s16.heap DEC_fill.st1.s15.next DEC_fill.st1.s16.next)
kernel_rfl DEC_fill.st1.fb15 : footRB DEC_fill.st1.s15 DEC_fill.st1.s16 DEC_fill.st1.fR15 = true
kernel_rfl DEC_fill.st1.fc15 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s15.next && Nat.ble DEC_fill.st1.s16.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR15 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa16 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s16 :=
  DEC_fill.st1.fa15.step (stageFoot_ofRF DEC_fill.st1.fh15 DEC_fill.st1.fb15) (incl_of_footW DEC_fill.st1.fb15 DEC_fill.st1.fc15)

def DEC_fill.st1.fR16 : List (Nat × Nat) := [(4841, 4842), (2672353, 2672354), (2992574, 2992575), (2992626, 2992627), (3139529, 3139537), (3139561, 3139562), (3139579, 3139580), (3139595, 3139597)]
kernel_rfl DEC_fill.st1.fh16 : DEC_fill.st1.s17.heap = setAll DEC_fill.st1.s16.heap (rangesOf DEC_fill.st1.s17.heap DEC_fill.st1.fR16 ++ freshOf DEC_fill.st1.s17.heap DEC_fill.st1.s16.next DEC_fill.st1.s17.next)
kernel_rfl DEC_fill.st1.fb16 : footRB DEC_fill.st1.s16 DEC_fill.st1.s17 DEC_fill.st1.fR16 = true
kernel_rfl DEC_fill.st1.fc16 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s16.next && Nat.ble DEC_fill.st1.s17.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR16 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa17 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s17 :=
  DEC_fill.st1.fa16.step (stageFoot_ofRF DEC_fill.st1.fh16 DEC_fill.st1.fb16) (incl_of_footW DEC_fill.st1.fb16 DEC_fill.st1.fc16)

def DEC_fill.st1.fR17 : List (Nat × Nat) := [(3139471, 3139474), (3139537, 3139544), (3139860, 3139861), (3140270, 3140271), (3140305, 3140306), (3140340, 3140341), (3140365, 3140367), (3140584, 3140585), (3140598, 3140599), (3140609, 3140610)]
kernel_rfl DEC_fill.st1.fh17 : DEC_fill.st1.s18.heap = setAll DEC_fill.st1.s17.heap (rangesOf DEC_fill.st1.s18.heap DEC_fill.st1.fR17 ++ freshOf DEC_fill.st1.s18.heap DEC_fill.st1.s17.next DEC_fill.st1.s18.next)
kernel_rfl DEC_fill.st1.fb17 : footRB DEC_fill.st1.s17 DEC_fill.st1.s18 DEC_fill.st1.fR17 = true
kernel_rfl DEC_fill.st1.fc17 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s17.next && Nat.ble DEC_fill.st1.s18.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR17 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa18 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s18 :=
  DEC_fill.st1.fa17.step (stageFoot_ofRF DEC_fill.st1.fh17 DEC_fill.st1.fb17) (incl_of_footW DEC_fill.st1.fb17 DEC_fill.st1.fc17)

def DEC_fill.st1.fR18 : List (Nat × Nat) := [(2672362, 2672363), (2994680, 2994681), (3123795, 3123796), (3139432, 3139433), (3139499, 3139500), (3140892, 3140893), (3140950, 3140951), (3140956, 3140957), (3140962, 3140963), (3141216, 3141217), (3141287, 3141288), (3141563, 3141564)]
kernel_rfl DEC_fill.st1.fh18 : DEC_fill.st1.s19.heap = setAll DEC_fill.st1.s18.heap (rangesOf DEC_fill.st1.s19.heap DEC_fill.st1.fR18 ++ freshOf DEC_fill.st1.s19.heap DEC_fill.st1.s18.next DEC_fill.st1.s19.next)
kernel_rfl DEC_fill.st1.fb18 : footRB DEC_fill.st1.s18 DEC_fill.st1.s19 DEC_fill.st1.fR18 = true
kernel_rfl DEC_fill.st1.fc18 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s18.next && Nat.ble DEC_fill.st1.s19.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR18 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa19 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s19 :=
  DEC_fill.st1.fa18.step (stageFoot_ofRF DEC_fill.st1.fh18 DEC_fill.st1.fb18) (incl_of_footW DEC_fill.st1.fb18 DEC_fill.st1.fc18)

def DEC_fill.st1.fR19 : List (Nat × Nat) := [(2672362, 2672363), (2995109, 2995110), (3141668, 3141671), (3141716, 3141721), (3141910, 3141911), (3142135, 3142136), (3142221, 3142222), (3142310, 3142311), (3142350, 3142355), (3142619, 3142620), (3142633, 3142636), (3142639, 3142641)]
kernel_rfl DEC_fill.st1.fh19 : DEC_fill.st1.s20.heap = setAll DEC_fill.st1.s19.heap (rangesOf DEC_fill.st1.s20.heap DEC_fill.st1.fR19 ++ freshOf DEC_fill.st1.s20.heap DEC_fill.st1.s19.next DEC_fill.st1.s20.next)
kernel_rfl DEC_fill.st1.fb19 : footRB DEC_fill.st1.s19 DEC_fill.st1.s20 DEC_fill.st1.fR19 = true
kernel_rfl DEC_fill.st1.fc19 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s19.next && Nat.ble DEC_fill.st1.s20.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR19 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa20 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s20 :=
  DEC_fill.st1.fa19.step (stageFoot_ofRF DEC_fill.st1.fh19 DEC_fill.st1.fb19) (incl_of_footW DEC_fill.st1.fb19 DEC_fill.st1.fc19)

def DEC_fill.st1.fR20 : List (Nat × Nat) := [(3123795, 3123796), (3141608, 3141609), (3141696, 3141697), (3143310, 3143311), (3143364, 3143365), (3143370, 3143371), (3143376, 3143377), (3143384, 3143385), (3143397, 3143399), (3143453, 3143454), (3143481, 3143482), (3143484, 3143494), (3143566, 3143567), (3143576, 3143577)]
kernel_rfl DEC_fill.st1.fh20 : DEC_fill.st1.s21.heap = setAll DEC_fill.st1.s20.heap (rangesOf DEC_fill.st1.s21.heap DEC_fill.st1.fR20 ++ freshOf DEC_fill.st1.s21.heap DEC_fill.st1.s20.next DEC_fill.st1.s21.next)
kernel_rfl DEC_fill.st1.fb20 : footRB DEC_fill.st1.s20 DEC_fill.st1.s21 DEC_fill.st1.fR20 = true
kernel_rfl DEC_fill.st1.fc20 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s20.next && Nat.ble DEC_fill.st1.s21.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR20 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa21 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s21 :=
  DEC_fill.st1.fa20.step (stageFoot_ofRF DEC_fill.st1.fh20 DEC_fill.st1.fb20) (incl_of_footW DEC_fill.st1.fb20 DEC_fill.st1.fc20)

def DEC_fill.st1.fR21 : List (Nat × Nat) := [(2672367, 2672368), (2997072, 2997073), (2997501, 2997502), (3144105, 3144112), (3144302, 3144303), (3144527, 3144528), (3144540, 3144541)]
kernel_rfl DEC_fill.st1.fh21 : DEC_fill.st1.s22.heap = setAll DEC_fill.st1.s21.heap (rangesOf DEC_fill.st1.s22.heap DEC_fill.st1.fR21 ++ freshOf DEC_fill.st1.s22.heap DEC_fill.st1.s21.next DEC_fill.st1.s22.next)
kernel_rfl DEC_fill.st1.fb21 : footRB DEC_fill.st1.s21 DEC_fill.st1.s22 DEC_fill.st1.fR21 = true
kernel_rfl DEC_fill.st1.fc21 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s21.next && Nat.ble DEC_fill.st1.s22.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR21 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa22 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s22 :=
  DEC_fill.st1.fa21.step (stageFoot_ofRF DEC_fill.st1.fh21 DEC_fill.st1.fb21) (incl_of_footW DEC_fill.st1.fb21 DEC_fill.st1.fc21)

def DEC_fill.st1.fR22 : List (Nat × Nat) := [(3123795, 3123796), (3144022, 3144023), (3144060, 3144063), (3144088, 3144089), (3144112, 3144113), (3145519, 3145520), (3145541, 3145545), (3145548, 3145549)]
kernel_rfl DEC_fill.st1.fh22 : DEC_fill.st1.s23.heap = setAll DEC_fill.st1.s22.heap (rangesOf DEC_fill.st1.s23.heap DEC_fill.st1.fR22 ++ freshOf DEC_fill.st1.s23.heap DEC_fill.st1.s22.next DEC_fill.st1.s23.next)
kernel_rfl DEC_fill.st1.fb22 : footRB DEC_fill.st1.s22 DEC_fill.st1.s23 DEC_fill.st1.fR22 = true
kernel_rfl DEC_fill.st1.fc22 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s22.next && Nat.ble DEC_fill.st1.s23.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR22 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa23 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s23 :=
  DEC_fill.st1.fa22.step (stageFoot_ofRF DEC_fill.st1.fh22 DEC_fill.st1.fb22) (incl_of_footW DEC_fill.st1.fb22 DEC_fill.st1.fc22)

def DEC_fill.st1.fR23 : List (Nat × Nat) := [(2672372, 2672373), (2999464, 2999465), (3146490, 3146500), (3146508, 3146509)]
kernel_rfl DEC_fill.st1.fh23 : DEC_fill.st1.s24.heap = setAll DEC_fill.st1.s23.heap (rangesOf DEC_fill.st1.s24.heap DEC_fill.st1.fR23 ++ freshOf DEC_fill.st1.s24.heap DEC_fill.st1.s23.next DEC_fill.st1.s24.next)
kernel_rfl DEC_fill.st1.fb23 : footRB DEC_fill.st1.s23 DEC_fill.st1.s24 DEC_fill.st1.fR23 = true
kernel_rfl DEC_fill.st1.fc23 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s23.next && Nat.ble DEC_fill.st1.s24.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR23 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa24 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s24 :=
  DEC_fill.st1.fa23.step (stageFoot_ofRF DEC_fill.st1.fh23 DEC_fill.st1.fb23) (incl_of_footW DEC_fill.st1.fb23 DEC_fill.st1.fc23)

def DEC_fill.st1.fR24 : List (Nat × Nat) := [(2672372, 2672373), (2999893, 2999894), (3146452, 3146455), (3146500, 3146505), (3146694, 3146695), (3146919, 3146920), (3147005, 3147006), (3147094, 3147095), (3147137, 3147139), (3147460, 3147461), (3147466, 3147467), (3147472, 3147473), (3147498, 3147503), (3147547, 3147548), (3147561, 3147571)]
kernel_rfl DEC_fill.st1.fh24 : DEC_fill.st1.s25.heap = setAll DEC_fill.st1.s24.heap (rangesOf DEC_fill.st1.s25.heap DEC_fill.st1.fR24 ++ freshOf DEC_fill.st1.s25.heap DEC_fill.st1.s24.next DEC_fill.st1.s25.next)
kernel_rfl DEC_fill.st1.fb24 : footRB DEC_fill.st1.s24 DEC_fill.st1.s25 DEC_fill.st1.fR24 = true
kernel_rfl DEC_fill.st1.fc24 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s24.next && Nat.ble DEC_fill.st1.s25.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR24 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa25 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s25 :=
  DEC_fill.st1.fa24.step (stageFoot_ofRF DEC_fill.st1.fh24 DEC_fill.st1.fb24) (incl_of_footW DEC_fill.st1.fb24 DEC_fill.st1.fc24)

def DEC_fill.st1.fR25 : List (Nat × Nat) := [(3123795, 3123796), (3146414, 3146415), (3146480, 3146481), (3148094, 3148095), (3148148, 3148149), (3148154, 3148155), (3148160, 3148161), (3148414, 3148415), (3148434, 3148436), (3148478, 3148479)]
kernel_rfl DEC_fill.st1.fh25 : DEC_fill.st1.s26.heap = setAll DEC_fill.st1.s25.heap (rangesOf DEC_fill.st1.s26.heap DEC_fill.st1.fR25 ++ freshOf DEC_fill.st1.s26.heap DEC_fill.st1.s25.next DEC_fill.st1.s26.next)
kernel_rfl DEC_fill.st1.fb25 : footRB DEC_fill.st1.s25 DEC_fill.st1.s26 DEC_fill.st1.fR25 = true
kernel_rfl DEC_fill.st1.fc25 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s25.next && Nat.ble DEC_fill.st1.s26.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR25 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa26 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s26 :=
  DEC_fill.st1.fa25.step (stageFoot_ofRF DEC_fill.st1.fh25 DEC_fill.st1.fb25) (incl_of_footW DEC_fill.st1.fb25 DEC_fill.st1.fc25)

def DEC_fill.st1.fR26 : List (Nat × Nat) := [(4841, 4842), (2672384, 2672385), (3001948, 3001949), (3002000, 3002001), (3148845, 3148848), (3148908, 3148918), (3149234, 3149235), (3149320, 3149321), (3149409, 3149410), (3149477, 3149478)]
kernel_rfl DEC_fill.st1.fh26 : DEC_fill.st1.s27.heap = setAll DEC_fill.st1.s26.heap (rangesOf DEC_fill.st1.s27.heap DEC_fill.st1.fR26 ++ freshOf DEC_fill.st1.s27.heap DEC_fill.st1.s26.next DEC_fill.st1.s27.next)
kernel_rfl DEC_fill.st1.fb26 : footRB DEC_fill.st1.s26 DEC_fill.st1.s27 DEC_fill.st1.fR26 = true
kernel_rfl DEC_fill.st1.fc26 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s26.next && Nat.ble DEC_fill.st1.s27.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR26 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa27 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s27 :=
  DEC_fill.st1.fa26.step (stageFoot_ofRF DEC_fill.st1.fh26 DEC_fill.st1.fb26) (incl_of_footW DEC_fill.st1.fb26 DEC_fill.st1.fc26)

def DEC_fill.st1.fR27 : List (Nat × Nat) := [(3123795, 3123796), (3148806, 3148807), (3148873, 3148874), (3150266, 3150267), (3150324, 3150325), (3150330, 3150331), (3150336, 3150337), (3150344, 3150345), (3150357, 3150359), (3150413, 3150414), (3150441, 3150442), (3150444, 3150454), (3150516, 3150517)]
kernel_rfl DEC_fill.st1.fh27 : DEC_fill.st1.s28.heap = setAll DEC_fill.st1.s27.heap (rangesOf DEC_fill.st1.s28.heap DEC_fill.st1.fR27 ++ freshOf DEC_fill.st1.s28.heap DEC_fill.st1.s27.next DEC_fill.st1.s28.next)
kernel_rfl DEC_fill.st1.fb27 : footRB DEC_fill.st1.s27 DEC_fill.st1.s28 DEC_fill.st1.fR27 = true
kernel_rfl DEC_fill.st1.fc27 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s27.next && Nat.ble DEC_fill.st1.s28.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR27 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa28 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s28 :=
  DEC_fill.st1.fa27.step (stageFoot_ofRF DEC_fill.st1.fh27 DEC_fill.st1.fb27) (incl_of_footW DEC_fill.st1.fb27 DEC_fill.st1.fc27)

def DEC_fill.st1.fR28 : List (Nat × Nat) := [(2672393, 2672394), (3004058, 3004059), (3004487, 3004488), (3151090, 3151097), (3151288, 3151289), (3151319, 3151320), (3151472, 3151473), (3151477, 3151478)]
kernel_rfl DEC_fill.st1.fh28 : DEC_fill.st1.s29.heap = setAll DEC_fill.st1.s28.heap (rangesOf DEC_fill.st1.s29.heap DEC_fill.st1.fR28 ++ freshOf DEC_fill.st1.s29.heap DEC_fill.st1.s28.next DEC_fill.st1.s29.next)
kernel_rfl DEC_fill.st1.fb28 : footRB DEC_fill.st1.s28 DEC_fill.st1.s29 DEC_fill.st1.fR28 = true
kernel_rfl DEC_fill.st1.fc28 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s28.next && Nat.ble DEC_fill.st1.s29.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR28 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa29 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s29 :=
  DEC_fill.st1.fa28.step (stageFoot_ofRF DEC_fill.st1.fh28 DEC_fill.st1.fb28) (incl_of_footW DEC_fill.st1.fb28 DEC_fill.st1.fc28)

def DEC_fill.st1.fR29 : List (Nat × Nat) := [(3151046, 3151049), (3151074, 3151075), (3151097, 3151099), (3152472, 3152473)]
kernel_rfl DEC_fill.st1.fh29 : DEC_fill.st1.s30.heap = setAll DEC_fill.st1.s29.heap (rangesOf DEC_fill.st1.s30.heap DEC_fill.st1.fR29 ++ freshOf DEC_fill.st1.s30.heap DEC_fill.st1.s29.next DEC_fill.st1.s30.next)
kernel_rfl DEC_fill.st1.fb29 : footRB DEC_fill.st1.s29 DEC_fill.st1.s30 DEC_fill.st1.fR29 = true
kernel_rfl DEC_fill.st1.fc29 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s29.next && Nat.ble DEC_fill.st1.s30.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR29 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa30 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s30 :=
  DEC_fill.st1.fa29.step (stageFoot_ofRF DEC_fill.st1.fh29 DEC_fill.st1.fb29) (incl_of_footW DEC_fill.st1.fb29 DEC_fill.st1.fc29)

def DEC_fill.st1.fR30 : List (Nat × Nat) := [(2672398, 2672399), (3006450, 3006451), (3123795, 3123796), (3150986, 3150987)]
kernel_rfl DEC_fill.st1.fh30 : DEC_fill.st1.s31.heap = setAll DEC_fill.st1.s30.heap (rangesOf DEC_fill.st1.s31.heap DEC_fill.st1.fR30 ++ freshOf DEC_fill.st1.s31.heap DEC_fill.st1.s30.next DEC_fill.st1.s31.next)
kernel_rfl DEC_fill.st1.fb30 : footRB DEC_fill.st1.s30 DEC_fill.st1.s31 DEC_fill.st1.fR30 = true
kernel_rfl DEC_fill.st1.fc30 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s30.next && Nat.ble DEC_fill.st1.s31.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR30 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa31 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s31 :=
  DEC_fill.st1.fa30.step (stageFoot_ofRF DEC_fill.st1.fh30 DEC_fill.st1.fb30) (incl_of_footW DEC_fill.st1.fb30 DEC_fill.st1.fc30)

def DEC_fill.st1.fR31 : List (Nat × Nat) := [(2672398, 2672399), (3006879, 3006880), (3153438, 3153441), (3153486, 3153491), (3153680, 3153681), (3153905, 3153906), (3153991, 3153992), (3154080, 3154081), (3154123, 3154125), (3154446, 3154447), (3154452, 3154453), (3154458, 3154459), (3154478, 3154489), (3154492, 3154493)]
kernel_rfl DEC_fill.st1.fh31 : DEC_fill.st1.s32.heap = setAll DEC_fill.st1.s31.heap (rangesOf DEC_fill.st1.s32.heap DEC_fill.st1.fR31 ++ freshOf DEC_fill.st1.s32.heap DEC_fill.st1.s31.next DEC_fill.st1.s32.next)
kernel_rfl DEC_fill.st1.fb31 : footRB DEC_fill.st1.s31 DEC_fill.st1.s32 DEC_fill.st1.fR31 = true
kernel_rfl DEC_fill.st1.fc31 : (Nat.ble DEC_fill.st1.s0.next DEC_fill.st1.s31.next && Nat.ble DEC_fill.st1.s32.next DEC_fill.st1.s150.next && coverB DEC_fill.st1.fR31 DEC_fill.st1.wrR DEC_fill.st1.s0.next) = true
theorem DEC_fill.st1.fa32 : FootAcc DEC_fill.st1.wr DEC_fill.st1.s150 DEC_fill.st1.s0 DEC_fill.st1.s32 :=
  DEC_fill.st1.fa31.step (stageFoot_ofRF DEC_fill.st1.fh31 DEC_fill.st1.fb31) (incl_of_footW DEC_fill.st1.fb31 DEC_fill.st1.fc31)

end Host.Load.Run.Tpl

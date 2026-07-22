/* Exact-pin, model-free Colibri capture harness.
 *
 * capture-colibri-glm52-oracle.ts copies this file and the temporary quant
 * header into an archived Colibri c/tests directory, then compiles it with the
 * recorded Apple clang toolchain. Including glm.c exposes the pinned static
 * helpers without modifying the source checkout.
 */

#define main coli_glm_main_unused
#include "../glm.c"
#undef main

#include "capture_quant.h"

static void print_float_array(const float *values, int count){
    putchar('[');
    for(int i=0;i<count;i++){ if(i) putchar(','); printf("%.9g",values[i]); }
    putchar(']');
}

static void print_int_array(const int *values, int count){
    putchar('[');
    for(int i=0;i<count;i++){ if(i) putchar(','); printf("%d",values[i]); }
    putchar(']');
}

static void print_u64_array(const uint64_t *values, int count){
    putchar('[');
    for(int i=0;i<count;i++){ if(i) putchar(','); printf("%llu",(unsigned long long)values[i]); }
    putchar(']');
}

static void capture_dsa(const char *name, const float *scores, int count, int keep){
    float *tmp=malloc((size_t)count*sizeof(float));
    int *selected=malloc((size_t)keep*sizeof(int));
    memcpy(tmp,scores,(size_t)count*sizeof(float));
    partial_select_desc(tmp,count,keep);
    float threshold=tmp[0];
    for(int i=1;i<keep;i++) if(tmp[i]<threshold) threshold=tmp[i];
    int nselected=0;
    for(int i=0;i<count&&nselected<keep;i++) if(scores[i]>threshold) selected[nselected++]=i;
    for(int i=0;i<count&&nselected<keep;i++) if(scores[i]==threshold) selected[nselected++]=i;
    printf("{\"name\":\"%s\",\"scores_f32\":",name);
    print_float_array(scores,count);
    printf(",\"keep\":%d,\"threshold_f32\":%.9g,\"selected\":",keep,threshold);
    print_int_array(selected,nselected);
    putchar('}');
    free(tmp); free(selected);
}

static void capture_lfru_case(const char *name, const uint32_t *heat, const uint32_t *last,
                              uint32_t clock, int count, const int *pinned, int npin){
    int slot=-1,eid=-1; long gain=0;
    int swap=tier_pick_lfru(heat,last,clock,count,pinned,npin,&slot,&eid,&gain);
    uint64_t *scores=malloc((size_t)count*sizeof(uint64_t));
    for(int i=0;i<count;i++) scores[i]=tier_lfru_score(heat[i],last[i],clock);
    printf("{\"name\":\"%s\",\"heat\":[",name);
    for(int i=0;i<count;i++){ if(i)putchar(','); printf("%u",heat[i]); }
    printf("],\"last\":[");
    for(int i=0;i<count;i++){ if(i)putchar(','); printf("%u",last[i]); }
    printf("],\"clock\":%u,\"pinned\":",clock); print_int_array(pinned,npin);
    printf(",\"scores_u64\":"); print_u64_array(scores,count);
    printf(",\"swap\":%s,\"slot\":%d,\"eid\":%d,\"gain\":%ld}",
           swap?"true":"false",swap?slot:-1,swap?eid:-1,swap?gain:0);
    free(scores);
}

int main(void){
    float i8_out[CAP_I8_S*CAP_I8_O];
    matmul_q(i8_out,cap_i8_x,(const int8_t*)cap_i8_q,cap_i8_s,
             CAP_I8_S,CAP_I8_I,CAP_I8_O);

    float i4_out[CAP_I4_S*CAP_I4_O];
    matmul_i4_grouped(i4_out,cap_i4_x,cap_i4_q,cap_i4_s,
                      CAP_I4_S,CAP_I4_I,CAP_I4_O,CAP_I4_GS);

    const float norm_x[4]={0.5f,-1.f,2.f,-0.25f};
    const float norm_w[4]={1.f,0.75f,1.25f,0.5f};
    float norm_out[4]; rmsnorm(norm_out,norm_x,norm_w,4,1e-6f);
    const float router_logits[10]={2.f,1.f,0.5f,0.f,-0.5f,-1.f,-2.f,-3.f,0.25f,-0.25f};
    float sigmoid_out[10]; for(int i=0;i<10;i++) sigmoid_out[i]=sigmoidf(router_logits[i]);

    const float dsa_ties[7]={0.1f,0.9f,0.5f,0.5f,0.7f,0.5f,-0.2f};
    const float dsa_equal[6]={0.25f,0.25f,0.25f,0.25f,0.25f,0.25f};
    const float dsa_all[3]={3.f,-1.f,2.f};
    const float dsa_negative[5]={-4.f,-1.f,-3.f,-1.f,-2.f};

    const uint32_t swap_heat[6]={3,8,7,20,4,2}, swap_last[6]={1,5,7,8,9,10};
    const int swap_pinned[3]={0,1,2};
    const uint32_t hold_heat[6]={8,9,10,13,12,11}, hold_last[6]={10,9,8,10,10,10};
    const int hold_pinned[3]={0,1,2};
    const uint32_t tie_heat[5]={10,10,18,18,18}, tie_last[5]={100,100,100,100,100};
    const int tie_pinned[2]={0,1};
    uint32_t decay[7]={0,1,2,3,4,15,16}; tier_decay(decay,7);

    printf("{\"target\":\"pinned_colibri_c_apple_arm64\",\"quantized_matmul\":{");
    printf("\"int8_f32\":"); print_float_array(i8_out,CAP_I8_S*CAP_I8_O);
    printf(",\"int4_grouped_f32\":"); print_float_array(i4_out,CAP_I4_S*CAP_I4_O);
    printf("},\"elementary\":{\"rmsnorm_f32\":"); print_float_array(norm_out,4);
    printf(",\"sigmoidf_f32\":"); print_float_array(sigmoid_out,10);
    printf("},\"dsa\":[");
    capture_dsa("threshold_tie_position_order",dsa_ties,7,4); putchar(',');
    capture_dsa("all_equal",dsa_equal,6,3); putchar(',');
    capture_dsa("keep_all_two_pass_order",dsa_all,3,3); putchar(',');
    capture_dsa("negative_scores",dsa_negative,5,2);
    printf("],\"lfru\":{\"cases\":[");
    capture_lfru_case("swap_hot_nonresident",swap_heat,swap_last,10,6,swap_pinned,3); putchar(',');
    capture_lfru_case("hold_inside_hysteresis",hold_heat,hold_last,10,6,hold_pinned,3); putchar(',');
    capture_lfru_case("tie_prefers_lower_slot_and_eid",tie_heat,tie_last,100,5,tie_pinned,2);
    printf("],\"wrap_score_case\":{\"heat\":5,\"last\":4294967295,\"clock\":2,\"score_u64\":%llu},",
           (unsigned long long)tier_lfru_score(5,UINT32_MAX,2));
    printf("\"decay_input\":[0,1,2,3,4,15,16],\"decay_expected\":[");
    for(int i=0;i<7;i++){ if(i)putchar(','); printf("%u",decay[i]); }
    printf("]}}\n");
    return 0;
}

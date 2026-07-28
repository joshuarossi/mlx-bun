/*
 * Bounded production-artifact oracle for the G2 GLM-5.2 dense probe.
 *
 * Compile this translation unit with:
 *   -DCOLIBRI_GLM_SOURCE=\"/absolute/path/to/colibri/c/glm.c\"
 *
 * Including the pinned engine source keeps this probe on Colibri's actual Q4
 * loader and dequant-to-f32-MAC implementation without initializing the full
 * 78-layer model. Only layer 0's gate/up/down tensors are read.
 */

#ifndef COLIBRI_GLM_SOURCE
#error "COLIBRI_GLM_SOURCE must name the pinned Colibri c/glm.c"
#endif

#define main colibri_embedded_main
#include COLIBRI_GLM_SOURCE
#undef main

static void read_f32_file(const char *path, float *values, size_t count) {
    FILE *file = fopen(path, "rb");
    if (!file) {
        perror(path);
        exit(2);
    }
    size_t got = fread(values, sizeof(float), count, file);
    if (got != count || fgetc(file) != EOF) {
        fprintf(stderr, "%s: expected exactly %zu float32 values, got %zu\n",
                path, count, got);
        fclose(file);
        exit(2);
    }
    fclose(file);
}

static void write_f32_file(const char *path, const float *values, size_t count) {
    FILE *file = fopen(path, "wb");
    if (!file) {
        perror(path);
        exit(2);
    }
    size_t wrote = fwrite(values, sizeof(float), count, file);
    if (wrote != count || fclose(file) != 0) {
        fprintf(stderr, "%s: failed to write %zu float32 values\n", path, count);
        exit(2);
    }
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "usage: %s MODEL_DIR INPUT_F32 OUTPUT_F32\n", argv[0]);
        return 2;
    }

    Model model;
    Layer layer;
    memset(&model, 0, sizeof(model));
    memset(&layer, 0, sizeof(layer));
    load_cfg(&model.c, argv[1]);
    st_init(&model.S, argv[1]);

    const int hidden = model.c.hidden;
    const int intermediate = model.c.dense_inter;
    if (hidden <= 0 || intermediate <= 0 || model.c.first_dense <= 0) {
        fprintf(stderr, "invalid dense geometry hidden=%d intermediate=%d first_dense=%d\n",
                hidden, intermediate, model.c.first_dense);
        return 2;
    }

    layer.gate_proj = qt_load(
        &model, "model.layers.0.mlp.gate_proj.weight",
        intermediate, hidden, 4
    );
    layer.up_proj = qt_load(
        &model, "model.layers.0.mlp.up_proj.weight",
        intermediate, hidden, 4
    );
    layer.down_proj = qt_load(
        &model, "model.layers.0.mlp.down_proj.weight",
        hidden, intermediate, 4
    );

    float *input = falloc(hidden);
    float *output = falloc(hidden);
    read_f32_file(argv[2], input, (size_t)hidden);

    g_idot = 0;
    dense_mlp(&layer, input, 1, hidden, intermediate, output);
    write_f32_file(argv[3], output, (size_t)hidden);

    fprintf(stderr,
            "[g2-dense-oracle] IDOT=0 rows=1 hidden=%d intermediate=%d\n",
            hidden, intermediate);
    return 0;
}

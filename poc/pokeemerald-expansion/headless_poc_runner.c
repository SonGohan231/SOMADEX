#include <limits.h>
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

#include <mgba/core/config.h>
#include <mgba/core/core.h>
#include <mgba/internal/gba/input.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Addresses for audited commit/build; re-resolve with arm-none-eabi-nm. */
#define SAVE_BLOCK_1_PTR_ADDRESS 0x030051D4
#define PARTIES_COUNT_ADDRESS 0x02031BF8

static void dump_ppm(const char *path, const uint32_t *pixels, size_t stride)
{
    FILE *out = fopen(path, "wb");
    if (!out) {
        perror(path);
        exit(2);
    }
    fprintf(out, "P6\n240 160\n255\n");
    for (unsigned y = 0; y < 160; y++) {
        for (unsigned x = 0; x < 240; x++) {
            uint32_t p = pixels[y * stride + x];
            fputc((p >> 0) & 0xFF, out);
            fputc((p >> 8) & 0xFF, out);
            fputc((p >> 16) & 0xFF, out);
        }
    }
    fclose(out);
}

int main(int argc, char **argv)
{
    if (argc < 3 || argc > 5) {
        fprintf(stderr, "usage: %s ROM OUT_PREFIX [SAVE_FILE] [restore]\n", argv[0]);
        return 2;
    }

    struct mCore *core = mCoreFind(argv[1]);
    if (!core || !core->init(core)) {
        fprintf(stderr, "could not initialize core\n");
        return 2;
    }
    uint32_t *pixels = calloc(256 * 256, sizeof(*pixels));
    core->setVideoBuffer(core, pixels, 256);
    if (!mCoreLoadFile(core, argv[1])) {
        fprintf(stderr, "could not load ROM\n");
        return 2;
    }
    char save_path[1024];
    snprintf(save_path, sizeof(save_path), "%s", argc >= 4 ? argv[3] : argv[2]);
    if (argc < 4)
        strncat(save_path, ".sav", sizeof(save_path) - strlen(save_path) - 1);
    if (!mCoreLoadSaveFile(core, save_path, false)) {
        fprintf(stderr, "could not load save file\n");
        return 2;
    }
    mCoreConfigInit(&core->config, "somadex-poc-runner");
    struct mCoreOptions opts = {0};
    opts.audioSync = false;
    opts.videoSync = false;
    mCoreConfigLoadDefaults(&core->config, &opts);
    mCoreConfigSetDefaultValue(&core->config, "idleOptimization", "detect");
    mCoreLoadConfig(core);
    core->reset(core);

    char trace_path[1024];
    snprintf(trace_path, sizeof(trace_path), "%s.log", argv[2]);
    FILE *trace = fopen(trace_path, "w");
    if (!trace)
        return 2;
    const int restore = argc == 5 && strcmp(argv[4], "restore") == 0;
    const unsigned end_frame = restore ? 3600 : 14000;

    for (unsigned frame = 0; frame <= end_frame; frame++) {
        uint32_t keys = 0;
        if (!restore && frame >= 240 && frame < 1500 && (frame % 120) < 3)
            keys |= 1u << GBA_KEY_SELECT;
        if (!restore && frame >= 1810 && frame < 1825)
            keys |= 1u << GBA_KEY_UP;
        if (!restore && ((frame >= 1850 && frame < 1853) || (frame >= 2000 && frame < 2003)
         || (frame >= 2200 && frame < 2203) || (frame >= 2400 && frame < 2403)))
            keys |= 1u << GBA_KEY_A;
        if (!restore && ((frame >= 2500 && frame < 2503) || (frame >= 2600 && frame < 2603)))
            keys |= 1u << GBA_KEY_B;
        if (!restore && frame >= 2700 && frame < 2730)
            keys |= 1u << GBA_KEY_DOWN;
        if (!restore && frame >= 3400 && frame < 12000 && (frame % 120) < 3)
            keys |= 1u << GBA_KEY_A;
        if (!restore && frame >= 12500 && frame < 12503)
            keys |= 1u << GBA_KEY_START;
        if (!restore && ((frame >= 12800 && frame < 12803) || (frame >= 12850 && frame < 12853)
         || (frame >= 12900 && frame < 12903) || (frame >= 12950 && frame < 12953)))
            keys |= 1u << GBA_KEY_DOWN;
        if (!restore && ((frame >= 13100 && frame < 13103) || (frame >= 13350 && frame < 13353)
         || (frame >= 13600 && frame < 13603)))
            keys |= 1u << GBA_KEY_A;
        if (restore && frame >= 360 && frame < 1900 && (frame % 180) < 3)
            keys |= 1u << GBA_KEY_A;
        if (restore && frame >= 2200 && frame < 2240)
            keys |= 1u << GBA_KEY_UP;
        if (restore && ((frame >= 2380 && frame < 2383) || (frame >= 2660 && frame < 2663)))
            keys |= 1u << GBA_KEY_A;

        core->setKeys(core, keys);
        core->runFrame(core);

        if (frame % 300 == 0 || frame == 1880 || frame == 2020 || frame == 2220
         || frame == 2420 || frame == 2620 || frame == 2740 || frame == 3420
         || frame == 4800 || frame == 6600 || frame == 8400 || frame == 9600
         || frame == 12000 || frame == 12520 || frame == 13120 || frame == 13620
         || frame == 14000) {
            char path[1024];
            snprintf(path, sizeof(path), "%s-%04u.ppm", argv[2], frame);
            dump_ppm(path, pixels, 256);
            uint32_t save1 = core->busRead32(core, SAVE_BLOCK_1_PTR_ADDRESS);
            fprintf(trace, "%u save1=%08x pos=%u,%u party=%u keys=%03x\n",
                    frame, save1,
                    save1 ? core->busRead16(core, save1) : 0,
                    save1 ? core->busRead16(core, save1 + 2) : 0,
                    core->busRead8(core, PARTIES_COUNT_ADDRESS), core->getKeys(core));
        }
    }

    fclose(trace);
    mCoreConfigFreeOpts(&opts);
    mCoreConfigDeinit(&core->config);
    core->deinit(core);
    free(pixels);
    return 0;
}

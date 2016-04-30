#if defined(__arm__) || defined(_ARM) || defined(_M_ARM) || defined(__arm)

#include <arm_neon.h>

void diffuseSpectrumSimdHelper(float32x4_t *posHist, int posIdx, float dfr) {
#if (1)
    asm volatile (
        "cmp %1, #0 \n"
        "bxle lr \n"
        "vdup.32 q11, %2 \n"
        "mov %1, %1, lsr #1 \n"
        "1: \n"
        "vldm %0, {d16-d19} \n"
        "subS %1, %1, #1 \n"
        "vsub.f32 q10, q8, q9 \n"
        "vmul.f32 q10, q10, q11 \n"
        "vadd.f32 q8, q8, q10 \n"
        "vsub.f32 q9, q9, q10 \n"
        "vstm %0!, {d16-d19} \n"
        "bne 1b \n"
        :
        : "r"(posHist), "r"(posIdx), "r"(dfr)
        : "d16","d17","d18","d19","d20","d21","d22","d23"
    );
#else
    int i;

    for (i = 0; i < posIdx; i += 2) {
        float32x4_t oo = (posHist[i] - posHist[i+1]);

        posHist[i] += oo * dfr;
        posHist[i+1] -= oo * dfr;
    }
#endif
}

#endif


#if defined(__x86_64) || defined(_M_X64) || defined(__i386) || defined(_M_IX86) || defined(_X86_) || defined(__THW_INTEL__) || defined(__I86__) || defined(__INTEL__)

#include <xmmintrin.h>

void diffuseSpectrumSimdHelper(__m128 *posHist, int posIdx, float dfr) {
    int i;

    for (i = 0; i < posIdx; i += 2) {
        __m128 oo = (posHist[i] - posHist[i+1]);

        posHist[i] += oo * dfr;
        posHist[i+1] -= oo * dfr;
    }
}

#endif

#if ( \
    defined(__aarch64__) || \
    defined(_M_ARM64) || \
    defined(_M_ARM64EC) \
)
    #define ARMV8 1
#else
    #undef ARMV8
#endif

#if (!defined(ARMV8)) && ( \
    (defined(__ARM_ARCH) && (__ARM_ARCH >= 7)) || \
    (defined(_M_ARM) && (_M_ARM >= 7)) || \
    (defined(__TARGET_ARCH_ARM) && (__TARGET_ARCH_ARM >= 7)) || \
    (defined(__TARGET_ARCH_THUMB) && (__TARGET_ARCH_THUMB >= 4)) \
)
    #define ARMV7 1
#else
    #undef ARMV7
#endif

#if (!defined(ARMV8)) && ( \
    defined(__amd64__) || \
    defined(__amd64) || \
    defined(__x86_64__) || \
    defined(__x86_64) || \
    defined(_M_X64) || \
    defined(_M_AMD64) \
)
    #define X64SSE2 1
#else
    #undef X64SSE2
#endif

#if (!defined(X64SSE2)) && ( \
    defined(__i386) || \
    defined(_M_IX86) || \
    defined(_X86_) || \
    defined(__THW_INTEL__) || \
    defined(__I86__) || \
    defined(__INTEL__) || \
    defined(__386) \
)
    #define X86SSE2 1
#else
    #undef X86SSE2
#endif


#if defined(ARMV7) || defined(ARMV8)

#include <arm_neon.h>

void diffuseSpectrumSimdHelper(float32x4_t *posHist, int posIdx, float dfr) {
#if (1)
#if defined(ARMV7) && defined(__GNUC__)
    if (posIdx <= 0) return;

    asm volatile (
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
        float32x4_t n1 = vld1q_f32((const float *)&(posHist[i]));
        float32x4_t n2 = vld1q_f32((const float *)&(posHist[i+1]));
        float32x4_t oo = n1 - n2;

        n1 += oo * dfr;
        n2 -= oo * dfr;
        vst1q_f32((float *)&(posHist[i]), n1);
        vst1q_f32((float *)&(posHist[i+1]), n2);
    }
#endif
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


#if defined(X86SSE2) || defined(X64SSE2)

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

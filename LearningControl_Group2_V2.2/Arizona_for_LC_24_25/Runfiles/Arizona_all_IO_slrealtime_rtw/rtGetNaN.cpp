/*
 * rtGetNaN.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "Arizona_all_IO".
 *
 * Model version              : 1.41
 * Simulink Coder version : 9.7 (R2022a) 13-Nov-2021
 * C++ source code generated on : Wed Apr 30 13:15:42 2025
 *
 * Target selection: slrealtime.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "rtwtypes.h"

extern "C" {

#include "rtGetNaN.h"

}
#include <stddef.h>

extern "C" {

#include "rt_nonfinite.h"

}
#define NumBitsPerChar                 8U

extern "C" {
  /*
   * Initialize rtNaN needed by the generated code.
   * NaN is initialized as non-signaling. Assumes IEEE.
   */
  real_T rtGetNaN(void)
  {
    size_t bitsPerReal = sizeof(real_T) * (NumBitsPerChar);
    real_T nan = 0.0;
    if (bitsPerReal == 32U) {
      nan = rtGetNaNF();
    } else {
      uint16_T one = 1U;
      enum {
        LittleEndian,
        BigEndian
      } machByteOrder = (*((uint8_T *) &one) == 1U) ? LittleEndian : BigEndian;
      switch (machByteOrder) {
       case LittleEndian:
        {
          union {
            LittleEndianIEEEDouble bitVal;
            real_T fltVal;
          } tmpVal;

          tmpVal.bitVal.words.wordH = 0xFFF80000U;
          tmpVal.bitVal.words.wordL = 0x00000000U;
          nan = tmpVal.fltVal;
          break;
        }

       case BigEndian:
        {
          union {
            BigEndianIEEEDouble bitVal;
            real_T fltVal;
          } tmpVal;

          tmpVal.bitVal.words.wordH = 0x7FFFFFFFU;
          tmpVal.bitVal.words.wordL = 0xFFFFFFFFU;
          nan = tmpVal.fltVal;
          break;
        }
      }
    }

    return nan;
  }

  /*
   * Initialize rtNaNF needed by the generated code.
   * NaN is initialized as non-signaling. Assumes IEEE.
   */
  real32_T rtGetNaNF(void)
  {
    IEEESingle nanF = { { 0.0F } };

    uint16_T one = 1U;
    enum {
      LittleEndian,
      BigEndian
    } machByteOrder = (*((uint8_T *) &one) == 1U) ? LittleEndian : BigEndian;
    switch (machByteOrder) {
     case LittleEndian:
      {
        nanF.wordL.wordLuint = 0xFFC00000U;
        break;
      }

     case BigEndian:
      {
        nanF.wordL.wordLuint = 0x7FFFFFFFU;
        break;
      }
    }

    return nanF.wordL.wordLreal;
  }
}

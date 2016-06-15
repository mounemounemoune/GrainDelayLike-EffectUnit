/**
 * Copyright (c) 2014,2015,2016 Enzien Audio Ltd.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#ifndef _SIGNAL_SAMPLE_H_
#define _SIGNAL_SAMPLE_H_

#include "HvBase.h"

typedef struct SignalSample {
  hv_uint32_t i; // timestamp at which to get sample
} SignalSample;

hv_size_t sSample_init(SignalSample *o);

void __hv_sample_f(HvBase *_c, SignalSample *o, hv_bInf_t bIn,
    void (*sendMessage)(HvBase *, int, const HvMessage *));

void sSample_onMessage(HvBase *_c, SignalSample *o, int letIndex, const HvMessage *m);

#endif // _SIGNAL_SAMPLE_H_

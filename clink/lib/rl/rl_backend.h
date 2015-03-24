/* Copyright (c) 2015 Martin Ridgers
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef RL_BACKEND_H
#define RL_BACKEND_H

#include "backend.h"

#ifdef __cplusplus

//------------------------------------------------------------------------------
class rl_backend
    : public backend
{
public:
                        rl_backend();
    virtual             ~rl_backend();
    virtual bool        edit_line(const wchar_t* prompt, wchar_t* out, int out_size) override;
    virtual const char* get_shell_name() const override;
    virtual void        set_shell_name(const char* name) override;

private:
};

#endif // __cplusplus

#ifdef __cplusplus
extern "C" {
#endif

backend_t* get_rl_backend();

#ifdef __cplusplus
}
#endif

#endif // RL_BACKEND_H

// vim: expandtab
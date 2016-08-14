// Copyright (c) 2013 Martin Ridgers
// License: http://opensource.org/licenses/MIT

#include "pch.h"
#include "host_ps.h"
#include "prompt.h"
#include "utils/hook_setter.h"
#include "utils/seh_scope.h"

#include <core/str.h>
#include <lib/line_editor.h>
#include <lua/lua_script_loader.h>
#include <process/vm.h>

#include <Windows.h>

//------------------------------------------------------------------------------
host_ps::host_ps()
: host("powershell.exe")
{
}

//------------------------------------------------------------------------------
host_ps::~host_ps()
{
}

//------------------------------------------------------------------------------
bool host_ps::validate()
{
    return true;
}

//------------------------------------------------------------------------------
bool host_ps::initialise()
{
    void* read_console_module = vm_region(ReadConsoleW).get_parent().get_base();
    if (read_console_module == nullptr)
        return false;

    hook_setter hooks;
    hooks.add_jmp(read_console_module, "ReadConsoleW", read_console);
    return (hooks.commit() == 1);
}

//------------------------------------------------------------------------------
void host_ps::shutdown()
{
}

//------------------------------------------------------------------------------
void host_ps::initialise_lua(lua_state& lua)
{
    lua_load_script(lua, app, powershell);
}

//------------------------------------------------------------------------------
void host_ps::initialise_editor_desc(line_editor::desc& desc)
{
    desc.quote_pair = "\"";
    desc.command_delims = ";";
    desc.word_delims = " \t<>";
    desc.partial_delims = "\\/:";
    desc.auto_quote_chars = " ;";
}

//------------------------------------------------------------------------------
BOOL WINAPI host_ps::read_console(
    HANDLE input,
    wchar_t* chars,
    DWORD max_chars,
    LPDWORD read_in,
    void* control)
{
    seh_scope seh;

    // Extract the prompt and reset the cursor to the beinging of the line
    // because it will get printed again.
    prompt prompt = prompt_utils::extract_from_console();

    CONSOLE_SCREEN_BUFFER_INFO csbi;
    HANDLE handle = GetStdHandle(STD_OUTPUT_HANDLE);
    GetConsoleScreenBufferInfo(handle, &csbi);
    csbi.dwCursorPosition.X = 0;
    SetConsoleCursorPosition(handle, csbi.dwCursorPosition);

    // Edit and add the CRLF that ReadConsole() adds when called.
    *chars = '\0';
    host_ps::get()->edit_line(prompt.get(), chars, max_chars);

    size_t len = max_chars - wcslen(chars);
    wcsncat(chars, L"\x0d\x0a", len);
    chars[max_chars - 1] = '\0';

    // Done!
    if (read_in != nullptr)
        *read_in = (DWORD)wcslen(chars);

    return TRUE;
}

//------------------------------------------------------------------------------
void host_ps::edit_line(const wchar_t* prompt, wchar_t* chars, int max_chars)
{
    str<128> utf8_prompt(prompt);
    str<1024> out;
    if (!host::edit_line(utf8_prompt.c_str(), out))
        out.copy("exit");

    to_utf16(chars, max_chars, out.c_str());
}
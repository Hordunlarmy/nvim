local M = {}

M.debugging_signs = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
}

M.diagnostic_signs = {
    Error = "E",
    Warn = "W",
    Hint = "H",
    Info = "I",
}

return M

vim.opt.runtimepath:prepend(vim.fn.getcwd())
local count = 0
local function test(name, fn)
    local ok, err = pcall(fn)
    if not ok then io.stderr:write("FAIL " .. name .. ": " .. tostring(err) .. "\n"); vim.cmd("cquit 1") end
    count = count + 1
    print("PASS " .. name)
end
test("chunked JSONL and trailing line", function()
    local lines = {}
    local feed, flush = require("cargo_diagnostics.stream").new_line_processor(function(s) table.insert(lines,s) end)
    feed('{"a":'); feed('1}\r\n\n{"b":2}'); flush(); flush()
    assert(vim.deep_equal(lines, {'{"a":1}', '{"b":2}'}))
end)
test("malformed JSON and event routing", function()
    local parse = require("cargo_diagnostics.parser.jsonl").parse_line
    assert(parse("{bad") == nil)
    local router = require("cargo_diagnostics.parser.cargo_router")
    assert(router.route(parse('{"reason":"compiler-artifact"}')) == nil)
    assert(router.route({reason="compiler-message",message={message="error"}}).type == "diagnostic")
end)
test("relative paths and primary span", function()
    local mapped = require("cargo_diagnostics.mapper").map_diagnostic({
        level="error", message="type mismatch",
        spans={{is_primary=true,file_name="src/main.rs",line_start=2,column_start=3,line_end=2,column_end=6}}
    }, {cwd=vim.fn.getcwd()})
    assert(mapped.filename == vim.fs.joinpath(vim.fn.getcwd(),"src/main.rs"))
    assert(mapped.diagnostic.lnum == 1 and mapped.diagnostic.col == 2)
end)
test("successful run clears stale diagnostics", function()
    local sink = require("cargo_diagnostics.sinks.diagnostic")
    local ns = vim.api.nvim_create_namespace("cargo_diagnostics")
    local filename = vim.fs.joinpath(vim.fn.getcwd(),"fixtures/demo/src/main.rs")
    sink.start(); sink.add({filename=filename,diagnostic={lnum=0,col=0,message="old",severity=1}}); sink.flush()
    assert(#vim.diagnostic.get(nil,{namespace=ns}) == 1)
    sink.start(); sink.flush()
    assert(#vim.diagnostic.get(nil,{namespace=ns}) == 0)
end)
test("public check calls exported executor; setup is repeatable", function()
    local commands = require("cargo_diagnostics.ui.commands")
    local original = commands.execute_cargo
    local called
    commands.execute_cargo = function(preset) called=preset end
    require("cargo_diagnostics").setup()
    require("cargo_diagnostics").setup()
    require("cargo_diagnostics").check()
    commands.execute_cargo = original
    assert(called == "check")
    assert(#vim.api.nvim_get_autocmds({group="CargoDiagnosticsCleanup"}) == 0)
end)
test("runner cancels previous process and ignores obsolete output", function()
    local original = vim.system
    local calls, callbacks, killed = {}, {}, false
    vim.system = function(_, opts, done)
        table.insert(calls,opts); table.insert(callbacks,done)
        return {kill=function() killed=true end}
    end
    local runner = require("cargo_diagnostics.runner")
    local lines, exits = {}, 0
    local function line(s) table.insert(lines,s) end
    local function done() exits=exits+1 end
    runner.run_cargo({args={"cargo"},cwd="."},line,done)
    runner.run_cargo({args={"cargo"},cwd="."},line,done)
    calls[1].stdout(nil,"old\n"); callbacks[1]({code=0})
    calls[2].stdout(nil,"new\n"); callbacks[2]({code=0})
    vim.wait(1000,function() return exits == 1 end)
    vim.system = original
    assert(killed and exits == 1 and vim.deep_equal(lines,{"new"}))
end)
print(string.format("%d tests passed",count))
vim.cmd("qa!")

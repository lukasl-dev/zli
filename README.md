# zli

**zli** is a composable, type-safe command-line interface library for Zig. It leverages `comptime` to define commands and flags, ensuring minimal runtime overhead and strict compile-time checks.

## Installation

Add `zli` to your `build.zig.zon`:

```bash
zig fetch --save git+https://github.com/lukasl-dev/zli
```

And to your `build.zig`:

```zig
const zli = b.dependency("zli", .{});
exe.root_module.addImport("zli", zli.module("zli"));
```

## Usage

Here is a clean example demonstrating how to define commands and pass a custom context.

```zig
const std = @import("std");

const AppState = struct {
    debug: bool = false,
};

const zli = @import("zli").customize(AppState);

const commands: []const zli.Command = &.{
    .{
        .name = "greet",
        .description = "Prints a greeting",
        .run = &runGreet,
    },
};

fn runGreet(ctx: zli.Context) !void {
    try ctx.stdout.print("Hello from zli!\n", .{});
    if (ctx.custom.debug) {
        try ctx.stdout.print("(Debug mode enabled)\n", .{});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var args = try std.process.argsWithAllocator(gpa.allocator());
    defer args.deinit();

    const exec = args.next() orelse return;

    var stdout_buf: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&stdout_buf);

    var stderr_buf: [4096]u8 = undefined;
    var stderr = std.fs.File.stderr().writer(&stderr_buf);

    var runner: zli.Commands(commands) = .init(
        &stdout.interface,
        &stderr.interface,
        exec,
    );

    const cmd_name = args.next() orelse {
        // no command provided: print help
        const manual: zli.print.Manual(commands) = .default;
        try manual.printContextless(&stdout.interface, exec);

        return;
    };

    const app_state: AppState = .{ .debug = true };
    runner.run(cmd_name, &args, app_state) catch |err| switch (err) {
        error.UnknownCommand => {
            try stderr.print("unknown command: {s}\n", .{cmd_name});
        },
        else => return err,
    };

    // don't forget to flush :)
    try stdout.interface.flush();
    try stderr.interface.flush();
}
```


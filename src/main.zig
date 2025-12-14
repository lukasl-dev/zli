const std = @import("std");

const Custom = struct {};
const zli = @import("zli").customize(Custom);

const commands: []const zli.Command = &.{foo_cmd};

const foo_cmd: zli.Command = .{
    .name = "foo",
    .description = "bar",
    .run = &foo_run,
};
const foo_flags: []const zli.Flag = &.{foo_flag};

const foo_flag: zli.Flag = .{
    .long = "flag",
    .short = 'f',
    .description = "Some flag",
    .accept = &foo_flag_accept,
};

fn foo_run(ctx: zli.Context) !void {
    const f: zli.Flags(foo_flags) = .default;
    f.acceptRemaining(ctx, null) catch |err| switch (err) {
        error.UnknownFlag => {
            const printer: zli.print.Flags(foo_flags) = .default;
            try printer.print(ctx);
            return;
        },
        else => return err,
    };

    try ctx.stdout.print("run\n", .{});
}

fn foo_flag_accept(ctx: zli.Context) !void {
    try ctx.stdout.print("flag accept\n", .{});
}

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();

    const exec = args.next().?;

    var stdout_buf: [1024]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&stdout_buf);

    var stderr_buf: [1024]u8 = undefined;
    var stderr = std.fs.File.stderr().writer(&stderr_buf);

    var runner: zli.Commands(commands) = .init(
        &stdout.interface,
        &stderr.interface,
        exec,
    );

    const name = args.next() orelse {
        const manual: zli.print.Manual(commands) = .default;
        try manual.printContextless(&stdout.interface, exec);
        return;
    };

    const custom: Custom = .{};
    runner.run(name, &args, custom) catch |err| switch (err) {
        else => return err,
    };

    try stdout.interface.flush();
    try stderr.interface.flush();
}

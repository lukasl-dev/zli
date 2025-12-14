const std = @import("std");

const Custom = struct {};
const zli = @import("zli").customize(Custom);

const commands: []const zli.Command = &.{};

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
    try runner.run(name, &args, custom);

    try stdout.interface.flush();
    try stderr.interface.flush();
}

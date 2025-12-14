const std = @import("std");
const zli = @import("zli");

pub fn Command(comptime Custom: type) type {
    return struct {
        name: []const u8,
        description: []const u8,
        run: *const fn (ctx: zli.Context(Custom)) anyerror!void,
    };
}

pub fn Commands(
    comptime Custom: type,
    comptime commands: []const Command(Custom),
) type {
    return struct {
        const Self = @This();

        stdout: *std.Io.Writer,
        stderr: *std.Io.Writer,

        exec: []const u8,

        pub const Error = error{
            UnknownCommand,
        };

        pub fn init(
            stdout: *std.Io.Writer,
            stderr: *std.Io.Writer,
            exec: []const u8,
        ) Self {
            return .{
                .stdout = stdout,
                .stderr = stderr,
                .exec = exec,
            };
        }

        pub fn context(
            self: Self,
            name: []const u8,
            args: *std.process.ArgIterator,
            custom: Custom,
        ) zli.Context(Custom) {
            return .{
                .stdout = self.stdout,
                .stderr = self.stderr,
                .exec = self.exec,
                .name = name,
                .args = args,
                .custom = custom,
            };
        }

        pub fn find(name: []const u8) ?Command(Custom) {
            inline for (commands) |cmd| {
                if (std.ascii.eqlIgnoreCase(cmd.name, name)) {
                    return cmd;
                }
            }
            return null;
        }

        pub fn run(
            self: Self,
            name: []const u8,
            args: *std.process.ArgIterator,
            custom: Custom,
        ) !void {
            const cmd = find(name) orelse return Error.UnknownCommand;

            const ctx = self.context(name, args, custom);
            try cmd.run(ctx);
        }
    };
}

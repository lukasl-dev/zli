const std = @import("std");

const zli = @import("zli");

pub fn Flags(
    comptime Custom: type,
    comptime flags: []const zli.Flag(Custom),
) type {
    comptime var max_len: usize = 0;
    inline for (flags) |flag| {
        var len = flag.long.len + 2;
        if (flag.short) |_| {
            len += 4;
        }
        if (flag.arg) |arg| {
            len += arg.len + 3;
        }
        if (len > max_len) max_len = len;
    }

    return struct {
        const Self = @This();

        pub const default: Self = .{};

        /// Prints a flags overview (for the given commands) to `out`, where
        /// `exec` is the name of the running executable (i.e. args[0]).
        pub fn printContextless(
            _: Self,
            out: *std.Io.Writer,
            exec: []const u8,
            cmd: []const u8,
        ) !void {
            try out.print(
                "Usage: {s} {s} [...flags] [...args]\n\n",
                .{ exec, cmd },
            );
            try out.print("Flags:\n", .{});

            inline for (flags) |flag| try printFlag(out, flag);

            try out.flush();
        }

        /// Prints a flags overview to stdout. Simplifies `printContextless` by
        /// obtaining the values from the context directly.
        pub fn print(self: Self, ctx: zli.Context(Custom)) !void {
            try self.printContextless(ctx.stdout, ctx.exec, ctx.name);
        }

        fn printFlag(out: *std.Io.Writer, flag: zli.Flag(Custom)) !void {
            const gap: usize = 4;

            var len = flag.long.len + 2;
            try out.print("  --{s}", .{flag.long});

            if (flag.short) |short| {
                try out.print(", -{c}", .{short});
                len += 4;
            }

            if (flag.arg) |arg| {
                try out.print(" <{s}>", .{arg});
                len += arg.len + 3;
            }

            const pad = gap + (max_len - len);
            for (0..pad) |_| try out.print(" ", .{});

            try out.print("{s}\n", .{flag.description});
        }
    };
}

const std = @import("std");

const zli = @import("zli");

pub fn Manual(
    comptime Custom: type,
    comptime commands: []const zli.Command(Custom),
) type {
    comptime var max_name_len: usize = 0;
    inline for (commands) |cmd| {
        if (cmd.name.len > max_name_len) {
            max_name_len = cmd.name.len;
        }
    }

    return struct {
        const Self = @This();

        pub const default: Self = .{};

        /// Prints a command overview (for the given commands) to `out`, where
        /// `exec` is the name of the running executable (i.e. args[0]).
        pub fn printContextless(
            _: Self,
            out: *std.Io.Writer,
            exec: []const u8,
        ) !void {
            try out.print(
                "Usage: {s} <command> [...flags] [...args]\n\n",
                .{exec},
            );
            try out.print("Commands:\n", .{});

            const gap: usize = 4;
            inline for (commands) |cmd| {
                try out.print("  {s}", .{cmd.name});

                const pad = gap + (max_name_len - cmd.name.len);
                for (0..pad) |_| try out.print(" ", .{});

                try out.print("{s}\n", .{cmd.description});
            }
            try out.print("\n", .{});
            try out.flush();
        }

        /// Prints a command-line overview to stdout. Simplifies
        /// `printContextless` by obtaining the values from the context
        /// directly.
        pub fn print(self: Self, ctx: zli.Context(Custom)) !void {
            try self.printContextless(ctx.stdout, ctx.exec);
        }
    };
}

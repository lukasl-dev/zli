const std = @import("std");
const eqlIgnoreCase = std.ascii.eqlIgnoreCase;

const zli = @import("zli");

fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn startsWith(haystack: []const u8, needle: []const u8) bool {
    return std.mem.startsWith(u8, haystack, needle);
}

pub fn Flag(comptime Custom: type) type {
    return struct {
        long: []const u8,
        short: u8,
        description: []const u8,
        accept: *const fn (ctx: zli.Context(Custom)) anyerror!void,
    };
}

pub fn Flags(
    comptime Custom: type,
    comptime flags: []const Flag(Custom),
) type {
    return struct {
        const Self = @This();

        pub const Error = error{
            /// Occurs when a flag was encountered that is unknown, i.e. does
            /// not exist in `flags`.
            UnknownFlag,

            /// Occurs when an unexpected arugment (which was not accepted by
            /// any flag) was encountered.
            UnexpectedArgument,
        };

        pub const default: Self = .{};

        /// Find a flag that matches the given arg. If none matches the given
        /// `arg`, `null` is returned.
        pub fn match(arg: []const u8) ?Flag(Custom) {
            const is_long = startsWith(arg, "--");
            const is_short = !is_long and startsWith(arg, "-");

            inline for (flags) |f| {
                if (arg.len > 1 and is_short and f.short == arg[1]) {
                    return f;
                }
                if (arg.len > 2 and is_long and eqlIgnoreCase(f.long, arg[2..])) {
                    return f;
                }
            }
            return null;
        }

        /// Check whether the given `arg` has valid flag formatting.
        inline fn isFlag(arg: []const u8) bool {
            return startsWith(arg, "--") or startsWith(arg, "-");
        }

        /// Accept the remaing arguments that are left in the `ctx.args`
        /// iterator.
        pub fn acceptRemaining(
            self: Self,
            ctx: zli.Context(Custom),
            on_arg: ?*const fn (
                ctx: zli.Context(Custom),
                arg: []const u8,
            ) anyerror!void,
        ) !void {
            while (ctx.args.next()) |arg| {
                if (!try self.accept(ctx, arg)) {
                    const oa = on_arg orelse return Error.UnexpectedArgument;
                    try oa(ctx, arg);
                }
            }
        }

        /// Accepts the given argument `arg`. The function returns whether `arg`
        /// is an existing flag. If `false` is returned, the given `arg` should
        /// be considered as an argument that was not accepted by any preceding
        /// flag.
        pub fn accept(
            _: Self,
            ctx: zli.Context(Custom),
            arg: []const u8,
        ) !bool {
            if (!isFlag(arg)) {
                return false;
            }

            const flag = match(arg) orelse return Error.UnknownFlag;
            try flag.accept(ctx);

            return true;
        }
    };
}

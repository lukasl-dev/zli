const command = @import("./command.zig");
const context = @import("./context.zig");
const flag = @import("./flag.zig");

pub const Command = command.Command;
pub const Commands = command.Commands;

pub const Context = context.Context;

pub const Flag = flag.Flag;
pub const Flags = flag.Flags;

pub const print = @import("./print/root.zig");

pub fn customize(comptime Custom: type) type {
    return struct {
        const C = @This();

        pub const Command = command.Command(Custom);

        pub fn Commands(comptime commands: []const C.Command) type {
            return command.Commands(Custom, commands);
        }

        pub const Context = context.Context(Custom);

        pub const Flag = flag.Flag(Custom);

        pub fn Flags(comptime flags: []const C.Flag) type {
            return flag.Flags(Custom, flags);
        }

        pub const print = @import("./print/root.zig").customize(Custom);
    };
}

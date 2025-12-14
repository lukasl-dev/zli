const zli = @import("zli");

const flags = @import("./flags.zig");
const manual = @import("./manual.zig");

pub const Flags = flags.Flags;
pub const Manual = manual.Manual;

pub fn customize(comptime Custom: type) type {
    return struct {
        pub fn Flags(comptime f: []const zli.Flag(Custom)) type {
            return flags.Flags(Custom, f);
        }

        pub fn Manual(comptime commands: []const zli.Command(Custom)) type {
            return manual.Manual(Custom, commands);
        }
    };
}

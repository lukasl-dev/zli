const zli = @import("zli");
const manual = @import("./manual.zig");

pub const Manual = manual.Manual;

pub fn customize(comptime Custom: type) type {
    return struct {
        pub fn Manual(comptime commands: []const zli.Command(Custom)) type {
            return manual.Manual(Custom, commands);
        }
    };
}

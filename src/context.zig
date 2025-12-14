const std = @import("std");

const zli = @import("zli");

pub fn Context(comptime Custom: type) type {
    return struct {
        const Self = @This();

        stdout: *std.Io.Writer,
        stderr: *std.Io.Writer,

        exec: []const u8,
        name: []const u8,
        args: *std.process.ArgIterator,

        custom: Custom,

        const Flag = zli.Flag(Custom);
        const Command = zli.Command(Custom);
    };
}

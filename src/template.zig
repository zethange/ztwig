const std = @import("std");
const Parser = @import("parser.zig").Parser;
const Token = @import("parser.zig").Token;
const Renderer = @import("renderer.zig").Renderer;

pub const Template = struct {
    template: []const u8,
    parser: Parser,
    tokens: []Token,
    allocator: std.mem.Allocator,
    const Self = @This();

    pub fn loadFromFile(allocator: std.mem.Allocator, file_path: []const u8) anyerror!Template {
        var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const path = try std.fs.realpath(file_path, &path_buffer);

        const file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |err| {
            std.debug.print("template file not found: {}\n", .{err});
            return err;
        };
        defer file.close();

        const file_stat = try file.stat();

        const buffer = try allocator.alloc(u8, file_stat.size);
        _ = try file.readAll(buffer);

        var t = Template{ .template = buffer, .parser = undefined, .tokens = undefined, .allocator = undefined };
        t.parser = Parser.init(&t, allocator);
        t.parse();
        t.allocator = allocator;

        return t;
    }

    pub fn loadFromString(str: []const u8) Template {
        var t = Template{ .template = str, .parser = undefined, .tokens = undefined, .allocator = undefined };
        t.parser = Parser.init(t);
        t.parse();

        return t;
    }

    fn parse(self: *Self) void {
        self.tokens = self.parser.parse() catch |err| {
            std.log.err("{any}\n", .{err});
            return;
        };
    }

    pub fn render(self: *Self, args: anytype) ![]u8 {
        var renderer = Renderer.init(self.allocator, self.tokens);
        return renderer.render(args);
    }
};

test "try to create template from string" {
    const t = Template.loadFromString("<html></html>");
    try std.testing.expectEqualStrings("<html></html>", t.template);
}

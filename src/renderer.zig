const std = @import("std");
const Token = @import("parser.zig").Token;

pub const Renderer = struct {
    const Self = @This();
    allocator: std.mem.Allocator,
    tokens: []Token,

    pub fn init(allocator: std.mem.Allocator, tokens: []Token) Renderer {
        return Renderer{ .allocator = allocator, .tokens = tokens };
    }

    pub fn render(self: *Self, args: anytype) ![]u8 {
        const ArgsType = @TypeOf(args);
        const fields = std.meta.fields(ArgsType);

        var res = std.ArrayList(u8).init(self.allocator);

        inline for (fields) |field| {
            const value = @field(args, field.name);
            std.debug.print("поле: {s}; значение: {s}\n", .{ field.name, value });
            for (self.tokens) |token| {
                if (token.type == .Identifier and std.mem.eql(u8, field.name, token.value)) {
                    try res.appendSlice(value);
                } else {
                    try res.appendSlice(token.value);
                }
            }
        }

        return res.items;
    }
};

const std = @import("std");
const print = @import("std").debug.print;
const heap = @import("std").heap;

const raw_input = @embedFile("../../input.dat");
const raw_input_length : usize = raw_input.len;

const Policy = struct {
    lowest: u32,
    highest: u32,
    char:   u8,
};

const PasswMap = struct {
    policy: Policy,
    passw: []const u8,
};

fn is_password_valid1(policy: Policy, passw: []const u8) bool {
    var encountered: u32 = 0;

    for (passw) |char| {
        if (char == policy.char) {
            encountered += 1;
        }
    }
    if (encountered < policy.lowest) {
        return false;
    }
    if (encountered > policy.highest) {
        return false;
    }
    return true;
}

fn is_password_valid2(policy: Policy, passw: []const u8) bool {
    if (passw[policy.lowest-1] == policy.char) {
        return passw[policy.highest-1] != policy.char;
    }
    else {
        return passw[policy.highest-1] == policy.char;
    }
}

fn parse_policys(input: []const u8, policys: []Policy) void {
    var curr_policy: usize = 0;
    var start_index_lowest: usize = 0;
    var start_index_highest: usize = 0;
    var feed_line: bool = false;
    for (input) |byte, i| {
        if (feed_line and byte == '\n') {
            start_index_lowest = i+1;
            feed_line = false;
            continue;
        }
        if (feed_line) {
            continue;
        }
        if (byte == '-') {
            policys[curr_policy].lowest = std.fmt.parseUnsigned(u32, input[start_index_lowest..i], 10) catch unreachable;
            start_index_highest = i+1;
            continue;
        }
        if (byte == ' ') {
            policys[curr_policy].highest = std.fmt.parseUnsigned(u32, input[start_index_highest..i], 10) catch unreachable;
            policys[curr_policy].char = input[i+1];
            curr_policy += 1;
            feed_line = true;
        }
    }

}

fn map_passwords(input: []const u8, passwords: [][]const u8) void {
    var curr_passw: usize = 0;
    var start_index: usize = 0;
    for (input) |byte, i| {
        if (byte == ':') {
            start_index = i+2;
            continue;
        }
        if (byte == '\n') {
            passwords[curr_passw] = input[start_index..i];
            curr_passw += 1;
        }
    }
}

fn rows_in_input(input: []const u8) usize {
    var rows: usize = 0;
    for (input) |char| {
        if (char == '\n') {
            rows += 1;
        }
    }
    return rows;
}

fn nr_valid_passwords1(policys: []Policy, passwords: [][]const u8) u32 {
    var nr_valid : u32 = 0;
    for (policys) |policy, i| {
        if (is_password_valid1(policy, passwords[i])) {
            nr_valid += 1;
        }
    }
    return nr_valid;
}
fn nr_valid_passwords2(policys: []Policy, passwords: [][]const u8) u32 {
    var nr_valid : u32 = 0;
    for (policys) |policy, i| {
        if (is_password_valid2(policy, passwords[i])) {
            nr_valid += 1;
        }
    }
    return nr_valid;
}

const alloc_config = heap.Config{};

pub fn main() anyerror!void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer std.testing.expect(!gpa.deinit());
    const allocator = &gpa.allocator;

    const nr_passw = rows_in_input(raw_input[0..]);

    var policys = try allocator.alloc(Policy, nr_passw);
    defer allocator.free(policys);

    var passwords = try allocator.alloc([]const u8, nr_passw);
    defer allocator.free(passwords);

    parse_policys(raw_input[0..], policys);
    map_passwords(raw_input[0..], passwords);

    const i : usize = 1;
    print(" First: {} \n highest: '{}'\n lowest: '{}' \n password: '{}'\n is valid1: '{}'\n is valid2: '{}'\n",
        .{policys[i].char,
          policys[i].highest,
          policys[i].lowest,
          passwords[i],
          is_password_valid1(policys[i], passwords[i]),
          is_password_valid2(policys[i], passwords[i]),
        });

    const valid_passwords1 = nr_valid_passwords1(policys[0..], passwords[0..]);
    const valid_passwords2 = nr_valid_passwords2(policys[0..], passwords[0..]);

    print(" Day: {} \n nr valid passwords1: '{}'\n nr valid passwords2: '{}'\n",
        .{2,
          valid_passwords1,
          valid_passwords2,
        });

}

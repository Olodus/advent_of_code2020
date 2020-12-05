const std = @import("std");
const print = @import("std").debug.print;
const heap = @import("std").heap;
const mem = @import("std").mem;

const raw_input = @embedFile("../../input.dat");
const raw_input_length : usize = raw_input.len;

const Passport = struct {
    byr: bool = false,
    iyr: bool = false,
    eyr: bool = false,
    hgt: bool = false,
    hcl: bool = false,
    ecl: bool = false,
    pid: bool = false,
    cid: bool = false,
};

fn check_byr(value: []const u8) bool {
    const val = std.fmt.parseUnsigned(u32, value, 10) catch return false;
    return (val >= 1920) and (val <= 2002);
}

fn check_iyr(value: []const u8) bool {
    const val = std.fmt.parseUnsigned(u32, value, 10) catch return false;
    return (val >= 2010) and (val <= 2020);
}

fn check_eyr(value: []const u8) bool {
    const val = std.fmt.parseUnsigned(u32, value, 10) catch return false;
    return (val >= 2020) and (val <= 2030);
}

fn check_hgt(value: []const u8) bool {
    const val = std.fmt.parseUnsigned(u32, value[0..value.len-2], 10) catch return false;
    if (mem.eql(u8, value[value.len-2..], "cm")) {
        return (val >= 150) and (val <= 193);
    }
    else if (mem.eql(u8, value[value.len-2..], "in")) {
        return (val >= 59) and (val <= 76);
    }
    else {
        return false;
    }
}

fn check_hcl(value: []const u8) bool {
    if ((value[0] == '#') and (value.len == 7)) {
        for (value[1..]) |byte| {
            if ((byte > '9' and byte < 'a') or (byte > 'f')) {
                return false;
            }
        }
        return true;
    }
    return false;
}
fn check_ecl(value: []const u8) bool {
    if (mem.eql(u8, value, "amb") or
        mem.eql(u8, value, "blu") or
        mem.eql(u8, value, "brn") or
        mem.eql(u8, value, "gry") or
        mem.eql(u8, value, "grn") or
        mem.eql(u8, value, "hzl") or
        mem.eql(u8, value, "oth")) {
        return true;
    }
    return false;
}
fn check_pid(value: []const u8) bool {
    if (value.len != 9) {
        return false;
    }
    const val = std.fmt.parseUnsigned(u32, value, 10) catch return false;
    return true;
}
fn check_cid(value: []const u8) bool {
    return true;
}

fn check_field(key: []const u8, value: []const u8, passport: *Passport) void {
    var res : bool = false;
    if (mem.eql(u8, key, "byr")) {
        passport.byr = check_byr(value);
        res = check_byr(value);
    }
    else if (mem.eql(u8, key, "iyr")) {
        passport.iyr = check_iyr(value);
        res = check_iyr(value);
    }
    else if (mem.eql(u8, key, "eyr")) {
        passport.eyr = check_eyr(value);
        res = check_eyr(value);
    }
    else if (mem.eql(u8, key, "hgt")) {
        passport.hgt = check_hgt(value);
        res = check_hgt(value);
    }
    else if (mem.eql(u8, key, "hcl")) {
        passport.hcl = check_hcl(value);
        res = check_hcl(value);
    }
    else if (mem.eql(u8, key, "ecl")) {
        passport.ecl = check_ecl(value);
        res = check_ecl(value);
    }
    else if (mem.eql(u8, key, "pid")) {
        passport.pid = check_pid(value);
        res = check_pid(value);
    }
    else if (mem.eql(u8, key, "cid")) {
        passport.cid = check_cid(value);
        res = check_cid(value);
    }
    //print(" Key='{}' Value:'{}' is '{}'\n",
    //    .{key,
    //      value,
    //      res,
    //    });
}

fn validate_passport(passport: Passport) bool {
    return
        passport.byr and
        passport.iyr and
        passport.eyr and
        passport.hgt and
        passport.hcl and
        passport.ecl and
        passport.pid;
}

fn check_fields(entries: [][]const u8, passports: []Passport) void {
    var key_start: usize = 0;
    var key_end: usize = 0;
    var value_start: usize = 0;

    for (entries) |curr_entry, entry_index| {
        for (curr_entry) |byte, i| {
            if (byte == ' ' or byte == '\n') {
                check_field(curr_entry[key_start..key_end],
                            curr_entry[value_start..i],
                            &passports[entry_index]);
                key_start = i+1;
                continue;
            }
            if (byte == ':') {
                key_end = i;
                value_start = i+1;
            }
        }
        key_start = 0;
    }

}

fn init_entries(input: []const u8, entries: [][]const u8) void {
    var curr_entry: usize = 0;
    var start_index: usize = 0;
    var was_newline: bool = false;
    for (input) |byte, i| {
        if (byte == '\n') {
            if (was_newline) {
                entries[curr_entry] = input[start_index..i];
                start_index = i+1;
                curr_entry += 1;
            }
            else {
                was_newline = true;
            }
        }
        else {
            was_newline = false;
        }
    }
    entries[curr_entry] = input[start_index..];
}

fn entries_in_input(input: []const u8) usize {
    var entries: usize = 0;
    var was_newline: bool = false;

    for (input) |char| {
        if (char == '\n') {
            if (was_newline) {
                entries += 1;
            }
            else {
                was_newline = true;
            }
        }
        else {
            was_newline = false;
        }
    }
    return entries + 1; // has to count the last one without two newlines also
}

fn count_valid_passports(passports: []Passport) u32 {
    var nr_valid: u32 = 0;
    for (passports) |passport| {
        if (validate_passport(passport)) {
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

    const nr_entries = entries_in_input(raw_input[0..]);

    var entries = try allocator.alloc([]const u8, nr_entries);
    defer allocator.free(entries);
    var passports = try allocator.alloc(Passport, nr_entries);
    defer allocator.free(passports);

    init_entries(raw_input[0..], entries);
    check_fields(entries[0..], passports[0..]);

    const i : usize = 8;
    print(" Passport '{}' is '{}'\n",
        .{i,
          validate_passport(passports[i]),
        });

    const nr_valid = count_valid_passports(passports[0..]);

    print(" Day: {} \n answer: '{}'\n",
        .{4,
          nr_valid,
        });

}

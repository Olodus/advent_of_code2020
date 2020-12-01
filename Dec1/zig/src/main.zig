const std = @import("std");
const print = @import("std").debug.print;
const parse = @import("std").fmt;

const raw_input = @embedFile("../../input.dat");
const raw_input_length : usize = raw_input.len;

const Answer = struct {
    answer: u32,
    fst: u32,
    snd: u32,
    trd: u32,
};

fn parse_input(input: []const u8, input_arr : []u32) void {
    var tape_index : usize = 0;
    var start : usize = 0;
    var end : usize = 0;
    for (input) |byte, i| {
        if (byte == '\n') {
            end = i;
            const num : u32 = std.fmt.parseInt(u32, input[start..end], 10) catch unreachable;
            input_arr[tape_index] = num;
            tape_index += 1;
            start = i + 1;
        }
    }
}

fn find_answer2(arr : []u32) ?Answer {
    for (arr) |first_val, i| {
        for (arr[i+1..]) |second_val| {
            if (first_val + second_val == 2020) {
                return Answer {
                    .answer = first_val * second_val,
                    .fst = first_val,
                    .snd = second_val,
                    .trd = 0,
                };
            }
        }
    }
    return null;
}

fn find_answer3(arr : []u32) ?Answer {
    for (arr) |first_val, i| {
        for (arr[i+1..]) |second_val, j| {
            for (arr[j+1..]) |third_val| {
                if (first_val + second_val + third_val == 2020) {
                    return Answer {
                        .answer = first_val * second_val * third_val,
                        .fst = first_val,
                        .snd = second_val,
                        .trd = third_val,
                    };
                }
            }
        }
    }
    return null;
}

pub fn main() anyerror!void {
    var refined_input = [_]u32{0} ** raw_input_length;
    parse_input(raw_input[0..], refined_input[0..]);

    const maybe_answer2 = find_answer2(refined_input[0..]);
    const answer2 = maybe_answer2 orelse unreachable;

    const maybe_answer3 = find_answer3(refined_input[0..]);
    const answer3 = maybe_answer3 orelse unreachable;

    print(" Day: {} \n answer2: '{}' \n answer3: '{}' \n  .fst: '{}', .snd: '{}', .trd: '{}' \n",
        .{1,
          answer2.answer,
          answer3.answer,
          answer3.fst,
          answer3.snd,
          answer3.trd
        });
}

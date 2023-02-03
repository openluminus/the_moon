%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin

// State
struct VotesCount {
    to_the_moon: felt,
    back_to_earth: felt,
}

struct VoterInfo {
    voted: felt,
    allowed: felt,
}

@storage_var
func voter_info(user_address: felt) -> (res: VoterInfo) {
}

@storage_var
func voting_state() -> (res: VotesCount) {
}

func register_voters{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    addresses_len: felt, addresses: felt*
) {
    // No voters left
    if (addresses_len == 0) {
        return ();
    }

    let v_info = VoterInfo(voted=0, allowed=1);
    voter_info.write(addresses[addresses_len - 1], v_info);

    // Go to the next voter
    return register_voters(addresses_len - 1, addresses);
}
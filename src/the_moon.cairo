%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
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

func assert_allowed_to_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: VoterInfo
) {
    // We check if caller is allowed to vote
    with_attr error_message("Address not allowed to vote.") {
        assert_not_zero(info.allowed);
    }

    return ();
}

func assert_did_not_vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    info: VoterInfo
) {
    // We check if caller hasn't already voted
    with_attr error_message("Address already voted.") {
        assert info.voted = 0;
    }
    return ();
}

@external
func vote{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(vote: felt) -> () {
    alloc_locals;
    let (caller) = get_caller_address();
    let (info) = voter_info.read(caller);

    assert_allowed_to_vote(info);
    assert_did_not_vote(info);

    // Set voted flag to true
    let new_info = VoterInfo(voted=1, allowed=1);
    voter_info.write(caller, new_info);

    let (state) = voting_state.read();
    // Add positive/negative vote
    local new_state: VotesCount;
    if (vote == 0) {
        assert new_state.to_the_moon = state.to_the_moon + 1;
        assert new_state.back_to_earth = state.back_to_earth;
    }
    if (vote == 1) {
        assert new_state.to_the_moon = state.to_the_moon;
        assert new_state.back_to_earth = state.back_to_earth + 1;
    }
    voting_state.write(new_state);
    return ();
}
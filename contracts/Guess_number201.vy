# @version ^0.2.0

#Contract Guess Number

struct game:
    game_owner: address
    secret_number: uint256
    game_balance: uint256
    guess_count: uint256
    is_active: bool

current_id: uint256

game_index: HashMap[uint256, game]

contract_owner: address

@external
def __init__():
    self.contract_owner = msg.sender
    self.current_id = 0

@external
@payable
def create_game(_secret_number: uint256) -> uint256:
    assert msg.value == 10*(10**18), "You should pay 10 ether to create a game"
    assert (_secret_number >= 0) and (_secret_number <= 100), "The secret number must be 0-100"
    self.game_index[self.current_id].game_owner = msg.sender
    self.game_index[self.current_id].game_balance = self.game_index[self.current_id].game_balance + msg.value
    self.game_index[self.current_id].secret_number = _secret_number
    self.game_index[self.current_id].guess_count = 0
    self.game_index[self.current_id].is_active = True
    self.current_id = self.current_id + 1
    return self.current_id - 1

@external
@view
def get_game_balance(_game_id: uint256) -> uint256:
    return self.game_index[_game_id].game_balance

@external
@view
def is_game_active(_game_id: uint256) -> bool:
    return self.game_index[_game_id].is_active

@external
@payable
def play(_game_id: uint256, _guessed_number: uint256) -> bool:
    assert msg.value == 1*(10**18)
    assert msg.sender != self.game_index[_game_id].game_owner
    assert self.game_index[_game_id].is_active == True
    self.game_index[_game_id].game_balance = self.game_index[_game_id].game_balance + msg.value
    self.game_index[_game_id].guess_count = self.game_index[_game_id].guess_count + 1
    if _guessed_number == self.game_index[_game_id].secret_number:
        send(msg.sender, (self.game_index[_game_id].game_balance *99)/100)
        send(self.contract_owner, self.game_index[_game_id].game_balance /100)
        self.game_index[_game_id].game_balance = 0
        self.game_index[_game_id].is_active = False
    else:
        if self.game_index[_game_id].guess_count == 10:
            send(self.game_index[_game_id].game_owner,(self.game_index[_game_id].game_balance *99)/100)
            send(self.contract_owner, self.game_index[_game_id].game_balance /100)
            self.game_index[_game_id].game_balance = 0
            self.game_index[_game_id].is_active = False
    return True
    
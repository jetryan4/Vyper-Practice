# @version ^0.2.0

#Contract Guess Number

secret_number: uint256
current_balance: public(uint256)
active: public(bool)


@external
@payable
def __init__(_secret_number: uint256):
    assert _secret_number >= 0 and _secret_number <= 100, "The secret number needs to be between 0-100"
    assert msg.value == 10*(10**18)
    self.secret_number = _secret_number
    self.current_balance = self.current_balance + msg.value
    self.active = True

@external
@payable
def play (_guessed_number: uint256):
    assert self.active == True, "This contract is already void"
    assert msg.value == 10**18
    if _guessed_number == self.secret_number:
        send(msg.sender,self.balance)
        self.current_balance = 0
        self.active = False

    



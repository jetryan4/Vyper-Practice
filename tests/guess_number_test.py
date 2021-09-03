import pytest
from brownie import Wei, accounts, Guess_number201

@pytest.fixture
def guess_number():
    guess_number = Guess_number201.deploy({'from':accounts[1]})
    guess_number.create_game(11, {'from':accounts[7], 'value':'10 ether'})
    return guess_number

def test_wrong_guess(guess_number):
    pre_game_balance = guess_number.get_game_balance(0)
    pre_player_balance = accounts[3].balance()
    pre_guess_count = guess_number.get_game_guesses(0)
    guess_number.play(0,5,{'from':accounts[3],'value':'1 ether'})
    assert guess_number.get_game_balance(0) == pre_game_balance + Wei('1 ether'), 'The game balance is not correct'
    assert accounts[3].balance() == pre_player_balance - Wei('1 ether'), 'Player balance incorrect'
    assert guess_number.get_game_guesses(0) == pre_guess_count + 1
    assert guess_number.is_game_active(0) == True
    return

def test_right_guess(guess_number):
    pre_game_balance = guess_number.get_game_balance(0)
    pre_player_balance = accounts[3].balance()
    pre_contract_owner_balance = accounts[1].balance()
    guess_number.play(0,11,{'from':accounts[3],'value':'1 ether'})
    assert guess_number.get_game_balance(0) == 0, "balance of the game is not reset"
    assert accounts[3].balance() == (pre_player_balance - Wei('1 ether')) + ((pre_game_balance + Wei('1 ether'))*99)/100, 'Player balance incorrect'
    assert accounts[1].balance() == pre_contract_owner_balance + (pre_game_balance + Wei('1 ether'))/100, "contract owner not paid correctly"
    assert guess_number.is_game_active(0) == False, "game is still active"
    return

def test_guess_max(guess_number):
    pre_game_balance = guess_number.get_game_balance(0)
    pre_player_balance = accounts[4].balance()
    pre_game_owner_balance = accounts[7].balance()
    pre_contract_owner_balance = accounts[1].balance()
    for i in range(10):
        guess_number.play(0,i,{'from':accounts[4],'value':'1 ether'})
    assert guess_number.get_game_balance(0) == 0, "balance of the game is not reset"
    assert accounts[4].balance() == (pre_player_balance - Wei('10 ether')), 'Player balance incorrect'
    assert accounts[7].balance() == pre_game_owner_balance + ((pre_game_balance + Wei('10 ether'))*99)/100, "game owner not paid correctly"
    assert accounts[1].balance() == pre_contract_owner_balance + (pre_game_balance + Wei('10 ether'))/100, "contract owner not paid correctly"
    assert guess_number.is_game_active(0) == False, "game is still active"
    return
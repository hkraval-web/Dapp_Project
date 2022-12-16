// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKidz {
    // owner DAD_HariPray
    address owner;

    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

    constructor() {
        owner = msg.sender;
    }

    // define Kid
    struct Kid {
        address payable walletAddress;
        string first_Name;
        string last_Name;
        uint release_Time;
        uint amount;
        bool canWithdraw;
    }

    Kid[] public kids;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }

    // add kid to contract
    function addKid(address payable walletAddress, string memory first_Name, string memory last_Name, uint release_Time, uint amount, bool canWithdraw) public onlyOwner {
        kids.push(Kid(
            walletAddress,
            first_Name,
            last_Name,
            release_Time,
            amount,
            canWithdraw
        ));
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    //deposit funds to contract, specifically to a kid's account
    function deposit(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private {
        for(uint i = 0; i < kids.length; i++) {
            if(kids[i].walletAddress == walletAddress) {
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint) {
        for(uint i = 0; i < kids.length; i++) {
            if (kids[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 999;
    }

    // kid checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > kids[i].release_Time, "You cannot withdraw yet");
        if (block.timestamp > kids[i].release_Time) {
            kids[i].canWithdraw = true;
            return true;
        } else {
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw");
        require(kids[i].canWithdraw == true, "You are not able to withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].amount);
    }

}

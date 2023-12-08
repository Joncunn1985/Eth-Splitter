// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Splitter {
    address public owner;
    address[21] public recipients;

    event EtherSplit(uint256 amount, address indexed sender);
    event RecipientUpdated(uint256 index, address indexed oldAddress, address indexed newAddress);
    event Received(address indexed sender, uint256 amount);
    event Withdrawal(uint256 amount, address indexed to);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        recipients = [
             0x09536eB28F206E5427355b73c1673c42feF37136,
        0x8aD5D1777eFF3F9713dF74E0260d7C94CAe6Bc68,
        0x0b9C8894998bEc6D2Ea399c5931679e333679373,
        0x21cc993362d17BdEf06837c1cAcBF5b311fF0D9b,
        0x7Ffd3BB22df14b077276addaBD22A40d8D2D9E9c,
        0x093869d515AC2E0C884A86ee3D431A26d723962e,
        0x6283bAb95C7cB3C001c01638866687F76ec119c2,
        0x1259f324074E3f2aA6a72D7191cd12A5b2F96A92,
        0x00E3877e94933E56a6ce74add37B5048BeC67135,
        0x7217B15e18309505d40BD973Ca23F5511473BB2D,
        0xaA67e558073E69a9Dff4B0b31684Ac3365100BD3,
        0x91dd918755670CE7E31B3f36c959EBAA2e17AFce,
        0x0007927B621693644b39404AA5f94fEFE235A364,
        0x2e17E0274Ff9B7418Bf7405bD65d8BA85bF6E6a3,
        0xb94Fe4b1b76B374650445f23AB32eb5629791BF5,
        0x41f7cAd817651Afc88422B914E92483B682679C5,
        0x82D8108144E99c0eA3DA31888cb8b4Bc4da308c4,
        0xf5841C7f1049d45aB13ec07508e1B5A4296845Ef,
        0x8a618Dda2A54c551315a65ea02f2d3fA66048eC4,
        0x75EB455C73f824622Fc443A15d19835985a26880,
        0xc56188b097987A03625f61DAaa73de148Aaeb734
        ];
    }

    function updateRecipient(uint256 index, address newRecipient) public onlyOwner {
        require(index < recipients.length, "Index out of bounds");
        emit RecipientUpdated(index, recipients[index], newRecipient);
        recipients[index] = newRecipient;
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        emit Withdrawal(amount, msg.sender);
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to withdraw BNB/ETH");
    }

    function splitETH() private {
        require(msg.value > 0, "No ETH sent");
        uint256 amountPerRecipient = msg.value / 21;
        for (uint256 i = 0; i < recipients.length; i++) {
            (bool sent, ) = recipients[i].call{value: amountPerRecipient}("");
            require(sent, "Failed to send Ether");
        }
        emit EtherSplit(msg.value, msg.sender);
    }

    // Fallback function to handle receiving Ether directly
    fallback() external payable {
        splitETH();
    }
   
    // Helper function to allow the contract to receive Ether with a plain transaction
    receive() external payable {
        emit Received(msg.sender, msg.value);
        splitETH();
    }
}
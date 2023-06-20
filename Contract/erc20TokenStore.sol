// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
interface IERC20 {
    function transfer(address recipient , uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenStorage is Ownable {
    struct Token {
        string tokenName;
        address tokenAddress;
        uint256 balance;
        bool active;
    }
    mapping(address => Token) public tokens;

    function storeToken(string memory _tokenName , address tokenAddress) external onlyOwner returns (bool){

       uint256 balance = IERC20(tokenAddress).balanceOf(address(this));
       require(balance > 0, "No balance in the contract for this token");
       tokens[tokenAddress] = Token(_tokenName , tokenAddress , balance , true);
       return true;
    }

    function retrieveToken(address tokenAddress) external onlyOwner returns(uint){
         Token storage token = tokens[tokenAddress];
         require(token.tokenAddress != address(0), "Token not found");
         require(token.active == true,"allready retrieve");
         IERC20(tokenAddress).transfer(msg.sender, token.balance);
         uint senderBalance = IERC20(tokenAddress).balanceOf(address(0));
         return senderBalance;

    }

}